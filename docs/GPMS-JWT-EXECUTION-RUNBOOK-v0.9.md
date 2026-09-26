# GPMS genuine-session execution runbook v0.9

**Scope:** Neon isolated branch `gpms-security-test` only. PR #11 stays DRAFT; production untouched.

## Preflight (required)
1. Verify Neon Auth is bound to the isolated branch and Data API exposes only `gpms`.
2. Resolve Issue #12 using a Neon-supported method. A direct SQL `SET ROLE authenticated; SELECT auth.uid()` currently fails because `authenticated` lacks USAGE on managed `auth` schema. Do not modify managed schema ownership, mint a substitute JWT, or claim that empty results prove isolation.
3. Obtain **genuine signed session JWTs** for synthetic Learner A, Learner B and Instructor through the branch's approved Neon Auth sign-in flow. The current synthetic `example.invalid` users have no demonstrated sign-in credentials; creating their user records alone does not provide sessions. Never put tokens/passwords in GitHub, logs, issues, or documentation. If the provider cannot issue sessions for these users, stop and record BLOCKED.
4. Verify each JWT subject matches its intended synthetic user through the provider-supported mechanism. Confirm intended role mapping, issuer/audience and expiry. Do not trust an unverified decoded payload as authentication evidence.
5. Provide the test-only Data API URL and tokens as ephemeral environment secrets to the read-only test runner; never print their values.

## Execution
Run `scripts/gpms-neon-jwt-isolation-gate-v2.mjs` with the three real signed sessions. The runner refuses other endpoint hosts and compares exact expected IDs for projects, submissions, versions and feedback. It also tests anonymous denial and denial of direct access to approval/audit tables. A passing exit status is necessary, not sufficient, for release.

## Additional mandatory checks before lifting HOLD
- Verify actual JWT role mapping and nonmember/unrelated-user denial.
- Run explicit negative INSERT/UPDATE/DELETE API checks with genuine sessions, using synthetic records only and proving no mutation. Current SQL role tests are separate evidence, not substitutes.
- Confirm learner ownership cannot be reassigned; no cross-project leakage in joins, counts, errors or filters.
- Require verified email and approved trusted staging origin before onboarding real students.
- Independently review RLS policies, API grants, constraints, logs, and branch/production separation.
- Capture dated evidence and reviewer approval in Issue #12. Keep PR #11 DRAFT until all gates pass.

## Current result
**NOT RUN / SECURITY HOLD.** No real signed JWTs are currently available through the connected tooling. Do not mark JWT isolation PASS.
