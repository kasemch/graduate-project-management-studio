-- DESIGN ONLY: NOT EXECUTED. Requires base migration and trusted submission RPC draft.
-- Privileged instructor transactions. No browser table write grants.
create or replace function public.gpms_add_feedback(p_submission_id uuid,p_body text)
returns uuid language plpgsql security definer set search_path='' as $$
declare v_actor uuid:=auth.uid(); v_project uuid; v_id uuid;
begin
 if v_actor is null or nullif(btrim(p_body),'') is null or length(p_body)>5000 then
 raise exception 'invalid feedback or authentication' using errcode='42501'; end if;
 select project_id into v_project from public.gpms_submissions where id=p_submission_id for update;
 if not found or not public.gpms_is_instructor(v_project) then raise exception 'access denied' using errcode='42501'; end if;
 insert into public.gpms_feedback(submission_id,author_id,body) values(p_submission_id,v_actor,btrim(p_body)) returning id into v_id;
 update public.gpms_submissions set status='reviewed' where id=p_submission_id;
 insert into public.gpms_audit_events(project_id,submission_id,actor_id,event_type)
 values(v_project,p_submission_id,v_actor,'feedback_added');
 return v_id;
end $$;

create or replace function public.gpms_approve_display(p_submission_id uuid,p_version_id uuid)
returns void language plpgsql security definer set search_path='' as $$
declare v_actor uuid:=auth.uid(); v_project uuid; v_status text; v_latest uuid;
begin
 if v_actor is null then raise exception 'authentication required' using errcode='42501'; end if;
 select project_id,status into v_project,v_status from public.gpms_submissions where id=p_submission_id for update;
 if not found or not public.gpms_is_instructor(v_project) or v_status<>'reviewed' then
 raise exception 'approval denied or not reviewed' using errcode='42501'; end if;
 select id into v_latest from public.gpms_submission_versions where submission_id=p_submission_id order by version_no desc limit 1;
 if v_latest is distinct from p_version_id then raise exception 'must approve latest version' using errcode='22023'; end if;
 -- Content moderation and student consent are not implemented: keep approval inactive.
 insert into public.gpms_display_approvals(submission_id,approved_version_id,approved_by,is_active)
 values(p_submission_id,p_version_id,v_actor,false)
 on conflict(submission_id) do update set approved_version_id=excluded.approved_version_id,approved_by=excluded.approved_by,approved_at=now(),is_active=false;
 insert into public.gpms_audit_events(project_id,submission_id,actor_id,event_type,version_id)
 values(v_project,p_submission_id,v_actor,'display_approved',p_version_id);
end $$;

create or replace function public.gpms_revoke_display(p_submission_id uuid)
returns void language plpgsql security definer set search_path='' as $$
declare v_actor uuid:=auth.uid(); v_project uuid; v_version uuid;
begin
 if v_actor is null then raise exception 'authentication required' using errcode='42501'; end if;
 select project_id into v_project from public.gpms_submissions where id=p_submission_id for update;
 if not found or not public.gpms_is_instructor(v_project) then raise exception 'access denied' using errcode='42501'; end if;
 update public.gpms_display_approvals set is_active=false where submission_id=p_submission_id returning approved_version_id into v_version;
 insert into public.gpms_audit_events(project_id,submission_id,actor_id,event_type,version_id)
 values(v_project,p_submission_id,v_actor,'display_revoked',v_version);
end $$;
revoke all on function public.gpms_add_feedback(uuid,text),public.gpms_approve_display(uuid,uuid),public.gpms_revoke_display(uuid) from public,anon;
grant execute on function public.gpms_add_feedback(uuid,text),public.gpms_approve_display(uuid,uuid),public.gpms_revoke_display(uuid) to authenticated;
-- Approval is deliberately inactive; no projector access until consent, moderation, session and cache invalidation exist.
