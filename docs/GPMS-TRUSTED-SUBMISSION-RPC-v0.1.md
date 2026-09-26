# GPMS Trusted Submission RPC — review contract v0.1

**Design only. Not executed or security certified.** The SQL is deliberately under `supabase/drafts/`, not `migrations/`. Do not apply it to staging or production.

`gpms_submit_version(submission_id, content, reason)` requires an authenticated owner with project membership, validates nonempty bounded text, locks the submission row, allocates the next version number, inserts an append-only version, transitions to submitted, revokes any active display approval, and records an audit event in one database transaction. It returns the new version ID and number. Failure rolls back all changes.

## Tests required before promotion
- Two concurrent calls for one submission produce distinct sequential versions and no lost updates.
- Another learner and another project's instructor cannot submit.
- Anonymous, blank and oversized input are rejected.
- Submitted/reviewed content is never overwritten; a new version is appended.
- Existing display approval is deactivated when a new version is submitted; projector delivery must also invalidate caches and active sessions.
- Direct INSERT/UPDATE/DELETE on versions and audit remain denied to browser roles.
- Audit event actor and project match the authenticated owner and submission.
- Confirm the function owner and SECURITY DEFINER privileges do not enable unintended access; review `search_path`, default EXECUTE and grants.
- Verify the base migration and this draft in a disposable local Supabase instance before promoting to an ordered migration.

Still missing: trusted instructor feedback transaction, moderated approval/revoke transactions, secure projector endpoint, project/member provisioning, privacy controls, automated negative JWT tests and actual SQL execution. The frontend remains synthetic-only.
