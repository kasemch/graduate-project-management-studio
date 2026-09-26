-- DESIGN-ONLY, NOT EXECUTED. Apply only after isolated local security review.
-- Trusted append-only version submission. No direct version insert grant to authenticated.
create table public.gpms_audit_events (
 id uuid primary key default gen_random_uuid(),
 project_id uuid not null references public.gpms_projects(id),
 submission_id uuid not null references public.gpms_submissions(id),
 actor_id uuid not null references auth.users(id),
 event_type text not null check(event_type in ('version_submitted','feedback_added','display_approved','display_revoked')),
 version_id uuid references public.gpms_submission_versions(id),
 occurred_at timestamptz not null default now()
);
alter table public.gpms_audit_events enable row level security;
create policy audit_read on public.gpms_audit_events for select to authenticated
 using(exists(select 1 from public.gpms_submissions s where s.id=submission_id
 and (s.owner_id=(select auth.uid()) or public.gpms_is_instructor(s.project_id))));
revoke insert,update,delete on public.gpms_audit_events from anon,authenticated;

create or replace function public.gpms_submit_version(p_submission_id uuid,p_content text,p_reason text)
returns table(version_id uuid,version_number integer)
language plpgsql security definer set search_path='' as $$
declare v_actor uuid := auth.uid(); v_submission public.gpms_submissions%rowtype; v_number integer; v_id uuid;
begin
 if v_actor is null then raise exception 'authentication required' using errcode='42501'; end if;
 if nullif(btrim(p_content),'') is null or nullif(btrim(p_reason),'') is null
 or length(p_content)>20000 or length(p_reason)>2000 then
 raise exception 'invalid submission content' using errcode='22023'; end if;
 select * into v_submission from public.gpms_submissions where id=p_submission_id for update;
 if not found or v_submission.owner_id<>v_actor or not public.gpms_is_member(v_submission.project_id) then
 raise exception 'submission access denied' using errcode='42501'; end if;
 if v_submission.status not in ('draft','submitted','reviewed') then
 raise exception 'invalid state' using errcode='22023'; end if;
 select coalesce(max(version_no),0)+1 into v_number from public.gpms_submission_versions where submission_id=p_submission_id;
 insert into public.gpms_submission_versions(submission_id,version_no,content,revision_reason,created_by)
 values(p_submission_id,v_number,p_content,p_reason,v_actor) returning id into v_id;
 update public.gpms_submissions set status='submitted' where id=p_submission_id;
 -- Prior approval must not survive a new version. No projector endpoint may cache an old approval.
 update public.gpms_display_approvals set is_active=false where submission_id=p_submission_id and is_active=true;
 insert into public.gpms_audit_events(project_id,submission_id,actor_id,event_type,version_id)
 values(v_submission.project_id,p_submission_id,v_actor,'version_submitted',v_id);
 return query select v_id,v_number;
end $$;
revoke all on function public.gpms_submit_version(uuid,text,text) from public,anon;
grant execute on function public.gpms_submit_version(uuid,text,text) to authenticated;
-- SECURITY HOLD: this function needs local tests of function owner, grants, RLS and approval invalidation.
