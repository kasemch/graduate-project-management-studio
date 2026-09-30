# GPMS Trusted Actor Gate v1.7 — 2026-09-29

## Actual isolated-branch checks
On Neon `gpms-security-test`, direct invocation of `gpms.set_membership_active(..., p_actor)` as `authenticated` and `gpms_app` was denied with function permission error; `anonymous` was denied schema access. Membership A remained active; membership_events count remained 4. SQL role simulation is not a signed JWT/RLS test. Prior CI run 36558111572 passed for v1.6.

## Critical design boundary
Current SECURITY DEFINER maintenance function accepts arbitrary `p_actor` and does not authorize its caller. **Do not grant EXECUTE to a browser or generic service role**; it is usable only by privileged maintenance under separate operational controls. Its argument is an asserted operator identifier, not a verified session identity. Existing synthetic events were written during privileged tests, not evidence of an authenticated operator.

## Approved target design (NOT IMPLEMENTED)
A trusted server endpoint verifies the provider-signed session and checks issuer, audience, expiry and approved institutional operator identity; checks a separate, explicit project-scoped administrator permission; derives actor UUID from verified server-side session (never client JSON); enforces CSRF/origin and idempotency; uses a dedicated least-privileged backend database role to invoke a new function with no actor argument. The database function must resolve the actor from a trusted transaction context established by that backend, recheck authorization, lock membership, change status and insert immutable event atomically. Do not trust client-set PostgreSQL GUCs or `SET ROLE` as authentication. The database owner/BYPASSRLS role is not an acceptable public backend credential.

Required negative tests: unauthenticated, unrelated learner, ordinary instructor, forged actor field, mismatched project, revoked operator, repeated transition, replay, event insertion failure, and no cross-project read; assert unchanged membership/event counts on denial. Genuine signed JWT matrix and provider-supported auth schema access remain blocked by Issue #12. Do not modify Neon-managed auth schema ad hoc.

## Release decision
SECURITY HOLD; PR #11 remains DRAFT. No production change, real student account, merge or deployment. This document is a design/denial evidence record, not implementation of trusted identity binding.
