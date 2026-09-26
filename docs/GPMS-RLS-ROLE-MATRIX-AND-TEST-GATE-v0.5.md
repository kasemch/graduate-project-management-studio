# GPMS RLS role matrix and test gate v0.5

Target: gpms-security-test only. SECURITY HOLD.

## Verified current state
Seven tables have RLS. Authenticated has SELECT only on projects, memberships, submissions, submission_versions and feedback. Anonymous has no gpms schema access. There are five preliminary SELECT policies: project creator, own membership, own submission, version of own submission, and feedback on own submission. There is no instructor membership policy and no write policy. The existing version and feedback policies query submissions, which is itself subject to RLS. Do not infer instructor visibility from project membership.

## Required acceptance matrix
- Anonymous: no application table access.
- Learner A: read own membership and own submissions/versions/feedback within authorized project; cannot read Learner B private work.
- Learner B: symmetric isolation.
- Instructor: access only projects for which an active instructor membership is established; permitted feedback and assessment must be project scoped.
- Unrelated authenticated account: no project data.
- All client roles: no direct writes to audit events or display approvals. Publication remains inactive.

## Test method
Use genuine synthetic Neon Auth accounts and signed sessions via the actual Data API. Confirm JWT subject to auth.uid() mapping, policy evaluation, and both positive and negative cases with nonempty synthetic fixtures. SQL SET ROLE and empty tables are only preliminary checks. Do not forge JWT or put service credentials in frontend. Add narrow write transactions only after these tests pass.

## Current blockers
The auth schema belongs to cloud_admin and authenticated lacks USAGE in direct role tests; verify provider-supported JWT request behavior rather than bypassing it. Neon Auth currently does not require email verification, so do not onboard real students. No staging origin has been approved. Production remains unchanged; do not merge PR #11.
