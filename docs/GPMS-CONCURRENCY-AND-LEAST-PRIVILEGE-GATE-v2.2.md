# GPMS Concurrency & Least Privilege Gate v2.2

## Verified isolated Neon branch
CI v2.1 run 36594623156 SUCCESS. Ledger 2, events 6, inactive memberships 0. Both ledger event references resolve; actor_id and project_id match the referenced events; unmatched rows 0. No non-owner grants on membership_events or membership_idempotency. Existing gpms_app and gpms_test_reader are NOLOGIN NOBYPASSRLS; authenticated and anonymous are NOLOGIN NOBYPASSRLS. Both membership transition functions are SECURITY DEFINER owned by neondb_owner, which BYPASSRLS; no client EXECUTE grants. This is not evidence of signed JWT authorization.

## Concurrency acceptance protocol (NOT YET EXECUTED)
Use two independent PostgreSQL connections to the isolated test branch with a dedicated synthetic key. Start transactions concurrently using a synchronization barrier, call the same idempotent transition, and record event IDs and replay flags. Require exactly one created and one replayed, same event ID, one ledger row, one event, final expected membership state. Repeat same key with different payload; require one success and one conflict. Inject event and ledger insertion failures; verify no partial state. Include timeouts, deadlock and transaction retry handling. Current connector calls are sequential and do not prove two-session concurrency. Never print credentials.

## Least-privilege target (DESIGN ONLY)
Trusted backend verifies provider-signed session and operator permission. Provision a separate NO-BYPASSRLS login role with only necessary schema/function EXECUTE and no direct table writes; do not reuse neondb_owner. A new server-only function must derive actor from trusted identity context and recheck project-scoped authorization; existing actor-parameter functions are not safe to expose. Use explicit EXECUTE grants, REVOKE PUBLIC, audited credential rotation and network isolation. The current role/function architecture does NOT satisfy this design yet. Old privileged function remains an operator maintenance bypass; isolate and govern it.

Issue #12: genuine JWT/RLS and managed auth schema blocker unresolved. PR #11 DRAFT; SECURITY HOLD; no production/real-student data or merge.
