# GPMS Full-Batch security result v1.2

Scope: isolated Neon branch only, synthetic data, no production changes.

## Verified
- PR #11 remains DRAFT and Issue #12 remains OPEN.
- Neon Auth has no trusted origins and does not currently require email verification; do not onboard real students.
- `auth` schema belongs to managed `cloud_admin`, with no `authenticated` USAGE. Direct `SET ROLE authenticated; SELECT auth.uid()` fails with permission denied. Real JWT/Data API test remains NOT RUN.
- Found missing composite owner-membership integrity. Added `submissions_owner_is_project_member` on test branch: `(project_id,owner_id)` references `memberships(project_id,user_id)`.
- Existing rows validated. Two synthetic invalid ownership insertions (cross-project learner and unrelated user) rejected. Count remains two submissions; zero rejected fixture rows persisted.
- Membership deletion is now restricted when a submission references it; retention/withdrawal behavior needs a deliberate design before real use.

## Provider evidence
Neon Data API documentation describes Neon Auth integration and `skip_auth_schema` provisioning option; this does not establish that reprovisioning fixes this branch's managed-schema ACL. Do not delete/reprovision Data API speculatively. Escalate provider-supported resolution for Issue #12; avoid modifying managed auth schema or faking signed JWT.

## Gate
SECURITY HOLD. No JWT isolation PASS, no PR merge, no production or student data.

## Membership lifecycle check (2026-09-29)
- Confirmed composite owner-membership FK still exists on isolated Neon branch.
- Synthetic fixture: 4 memberships, 2 submissions; each learner owns one submission, instructor owns none.
- Attempt to delete learner A membership with owned submission was rejected by foreign key.
- Attempt to delete instructor membership (no owned submission) succeeded within a test statement, triggering an explicit test exception; the statement was rolled back. Subsequent counts remained 4 memberships and 2 submissions.
- **Design gap:** owner-membership FK preserves ownership but does not retain instructor membership or historical reviewer attribution. Before real use, design explicit active/inactive membership lifecycle, historical role snapshot and revocation semantics. Do not claim the FK alone solves withdrawal or audit retention.
- Latest prior CI run 36518358119 completed success. This result predates this documentation update and is not genuine JWT/RLS evidence.
