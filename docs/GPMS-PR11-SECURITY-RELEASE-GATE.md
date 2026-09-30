# GPMS PR #11 — Security Release Gate (updated)

Status: **ISOLATED NEON BRANCH TESTED IN PART; GENUINE JWT NOT RUN; SECURITY HOLD; PRODUCTION UNCHANGED**.

## Verified
- PR #11 is Draft; Issue #12 remains open.
- Synthetic Neon branch `gpms-security-test` contains two projects, distinct learner ownership, instructor memberships and unrelated nonmember account.
- All seven GPMS tables have RLS. Authenticated direct writes and anonymous direct reads were denied in SQL role tests; those tests are not JWT tests.
- Composite foreign keys reject cross-submission approval, cross-project audit and nonmember submission ownership on the isolated branch.
- GitHub quality workflow builds the frontend and runs static SQL guardrails; JWT test scripts receive syntax checks only, with no credentials/network in CI.
- `supabase/drafts/` remains draft material, **not** a production or Neon migration chain. Branch-only Neon deltas are documented separately.

## Blocking
- Managed `auth` schema lacks USAGE for `authenticated` in direct role test; `auth.uid()` fails. Determine provider-supported resolution and verify actual Data API signed JWT behavior; see Issue #12.
- Obtain real signed Neon Auth sessions for learner A/B, instructor and unrelated account. Run exact positive and negative visibility tests; no synthetic/fake JWT substitutes.
- Test API writes and ownership constraints under genuine sessions, concurrency, and server-side transaction design.
- Configure verified email and approved trusted staging origin before real student onboarding.
- Complete consent, moderation, revocation, privacy/retention, independent security review and end-to-end frontend acceptance.

## Decision
Do not merge PR #11 as an operational backend, activate student access, or modify production. A green CI build does not satisfy the security release gate. Keep Issue #12 open until dated evidence is attached and independently reviewed.
