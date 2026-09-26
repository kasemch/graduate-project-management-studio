-- SECURITY HOLD: DESIGN-ONLY SQL. DO NOT APPLY TO STAGING OR PRODUCTION.
-- Known gaps: mutable ownership/project fields, direct status transitions, non-atomic version numbers,
-- incomplete immutable audit, no projector service or content moderation. See docs/GPMS-RLS-NEGATIVE-TEST-PLAN-v0.1.md.
-- GPMS schema draft: staging only. Requires Supabase Auth and security review.
create extension if not exists pgcrypto;
create table public.gpms_projects(id uuid primary key default gen_random_uuid(), title text not null, created_by uuid not null references auth.users(id), created_at timestamptz not null default now());
create table public.gpms_memberships(project_id uuid not null references public.gpms_projects(id) on delete cascade, user_id uuid not null references auth.users(id), role text not null check(role in ('learner','instructor')), primary key(project_id,user_id));
create table public.gpms_submissions(id uuid primary key default gen_random_uuid(), project_id uuid not null references public.gpms_projects(id), owner_id uuid not null references auth.users(id), activity_code text not null, status text not null default 'draft' check(status in ('draft','submitted','reviewed')), created_at timestamptz not null default now());
create table public.gpms_submission_versions(id uuid primary key default gen_random_uuid(), submission_id uuid not null references public.gpms_submissions(id), version_no integer not null check(version_no>0), content text not null, revision_reason text not null, created_by uuid not null references auth.users(id), created_at timestamptz not null default now(), unique(submission_id,version_no));
create table public.gpms_feedback(id uuid primary key default gen_random_uuid(), submission_id uuid not null references public.gpms_submissions(id), author_id uuid not null references auth.users(id), body text not null, created_at timestamptz not null default now());
create table public.gpms_display_approvals(submission_id uuid primary key references public.gpms_submissions(id), approved_version_id uuid not null references public.gpms_submission_versions(id), approved_by uuid not null references auth.users(id), approved_at timestamptz not null default now(), is_active boolean not null default false);
create or replace function public.gpms_is_instructor(pid uuid) returns boolean language sql stable security definer set search_path='' as $$select exists(select 1 from public.gpms_memberships m where m.project_id=pid and m.user_id=(select auth.uid()) and m.role='instructor')$$;
create or replace function public.gpms_is_member(pid uuid) returns boolean language sql stable security definer set search_path='' as $$select exists(select 1 from public.gpms_memberships m where m.project_id=pid and m.user_id=(select auth.uid()))$$;
revoke all on function public.gpms_is_instructor(uuid),public.gpms_is_member(uuid) from public;
grant execute on function public.gpms_is_instructor(uuid),public.gpms_is_member(uuid) to authenticated;
alter table public.gpms_projects enable row level security;
alter table public.gpms_memberships enable row level security;
alter table public.gpms_submissions enable row level security;
alter table public.gpms_submission_versions enable row level security;
alter table public.gpms_feedback enable row level security;
alter table public.gpms_display_approvals enable row level security;
create policy project_read on public.gpms_projects for select to authenticated using(public.gpms_is_member(id));
create policy membership_read on public.gpms_memberships for select to authenticated using(user_id=(select auth.uid()) or public.gpms_is_instructor(project_id));
create policy submission_read on public.gpms_submissions for select to authenticated using(owner_id=(select auth.uid()) or public.gpms_is_instructor(project_id));
create policy submission_insert on public.gpms_submissions for insert to authenticated with check(owner_id=(select auth.uid()) and public.gpms_is_member(project_id));
-- No direct submission UPDATE policy: trusted transition RPC is required before real use.
create policy version_read on public.gpms_submission_versions for select to authenticated using(exists(select 1 from public.gpms_submissions s where s.id=submission_id and (s.owner_id=(select auth.uid()) or public.gpms_is_instructor(s.project_id))));
-- No direct version INSERT policy: atomic server-side version creation is required.
create policy feedback_read on public.gpms_feedback for select to authenticated using(exists(select 1 from public.gpms_submissions s where s.id=submission_id and (s.owner_id=(select auth.uid()) or public.gpms_is_instructor(s.project_id))));
create policy feedback_insert on public.gpms_feedback for insert to authenticated with check(author_id=(select auth.uid()) and exists(select 1 from public.gpms_submissions s where s.id=submission_id and public.gpms_is_instructor(s.project_id)));
create policy display_read on public.gpms_display_approvals for select to authenticated using(exists(select 1 from public.gpms_submissions s where s.id=submission_id and (s.owner_id=(select auth.uid()) or public.gpms_is_instructor(s.project_id))));
-- No direct display INSERT policy: reviewed, moderated server-side approval required.
-- No direct display UPDATE policy: revocation and audit must be server-side.
-- No anonymous policies, no public projector view. Instructor membership provisioning is server-side only.

-- Defense in depth: no direct mutation of immutable or privileged tables by browser roles.
revoke insert,update,delete on public.gpms_memberships from anon,authenticated;
revoke update,delete on public.gpms_submission_versions from anon,authenticated;
revoke insert,update,delete on public.gpms_display_approvals from anon,authenticated;
revoke update,delete on public.gpms_feedback from anon,authenticated;
revoke update,delete on public.gpms_projects from anon,authenticated;
revoke update,delete on public.gpms_submissions from anon,authenticated;
-- This migration remains DESIGN-ONLY. No privileged RPCs or real-data readiness is implied.
