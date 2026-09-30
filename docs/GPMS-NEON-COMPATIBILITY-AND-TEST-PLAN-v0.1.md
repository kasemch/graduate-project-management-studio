# GPMS Neon compatibility and isolated security test plan v0.1

Status: DESIGN ONLY / NO MIGRATION / NO REAL STUDENT DATA.
Neon project: soft-lab-14586372. Test branch: gpms-security-test (br-summer-breeze-b3zygsl6). Never use the default production branch for these tests.

## Verified environment
Neon PostgreSQL 18.6, neondb, public schema. The test branch has no application tables, no auth schema, no authenticated role, and no pgcrypto extension at inspection time. The original Supabase SQL is not portable unchanged: auth.users, auth.uid(), and authenticated/anon roles are Supabase-specific. Do not create a fake auth.uid() and treat it as real authorization.

## Identity and threat model gate
Choose and document a trusted authentication provider, verified JWT claims, and a server-side request-to-database identity propagation mechanism before RLS execution. A browser must never be able to set its own trusted user ID via an arbitrary session setting. Separate migration owner, application runtime role, and test impersonation role. No privileged connection string in client code or git. Validate transaction-scoped identity and pooled connection isolation. Decide how the service authenticates database calls and how instructor membership is provisioned.

## Migration design
Create Neon-specific migration files in a separate drafts/neon directory. Preserve original supabase/drafts unchanged. Use gen_random_uuid() supported by PostgreSQL 18; verify extension requirements rather than installing by assumption. Replace auth.users foreign keys with a controlled application identity mapping only after the auth-provider decision. Rework policies to use a server-trusted actor context; restrict table ownership, grants, function execution and SECURITY DEFINER search_path. No projector or active public display until consent, moderation, revocation and cache invalidation exist.

## Test matrix (synthetic identities only)
- Anonymous: no project, submission, feedback, audit or approval access.
- Learner A: only own project-scoped submission and versions; cannot mutate membership, ownership, audit, feedback or approvals.
- Learner B: cannot read/write A's submission, versions or feedback; forged project_id and owner_id denied.
- Instructor A: project-scoped feedback only through audited trusted transaction; cannot access another project's records.
- Cross-project and missing membership denied.
- Submit-version: concurrent calls yield unique monotonic version numbers, append-only records, atomic status/audit updates and prior display invalidation.
- Feedback: reviewed transition and audit atomic; no direct browser write.
- Display approval: inactive by default; latest-version constraint; revocation and re-submission invalidate approval.
- Identity spoofing: untrusted caller cannot impersonate another user or preserve another request's identity on a pooled connection.
- RLS owner bypass, SECURITY DEFINER owner, search_path, role grants and function EXECUTE verified explicitly.

## Execution gate
1. Approve authentication and identity propagation design.
2. Review Neon draft SQL and negative tests.
3. Apply only to gpms-security-test with synthetic fixtures and explicit branch ID.
4. Capture actual SQL execution results and failure cases; do not substitute static checks.
5. Keep PR #11 draft and production deployment HOLD until the security gate is met.

No migration, user provisioning, SQL DDL, production changes or live-data processing are authorized by this document.
