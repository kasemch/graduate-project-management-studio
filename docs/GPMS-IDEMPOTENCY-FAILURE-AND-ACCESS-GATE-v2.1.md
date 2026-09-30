# GPMS Idempotency Failure & Access Gate v2.1

CI v2.0 run 36581735552 SUCCESS. Isolated Neon test branch only.

Baseline ledger=2, events=6, synthetic learner A active=true. Added a temporary CHECK in a PL/pgSQL exception subtransaction to reject idempotency key `idempotency_fail_0003` on ledger INSERT. Invoking maintenance-only `set_membership_active_once` attempted membership update + event insert + ledger insert, then failed on ledger CHECK. The exception handler rolled back the subtransaction, including the temporary CHECK. Postcondition ledger=2, events=6, learner active=true, temporary constraint count=0. This tests atomic failure rollback; it is not a concurrent two-session test.

SQL privilege checks show authenticated, anonymous and gpms_app all lack EXECUTE on both old `set_membership_active(uuid,uuid,boolean,uuid)` and new `set_membership_active_once(uuid,uuid,boolean,uuid,text)`. The privileged owner can still invoke the old path without ledger; it remains a maintenance bypass, not a browser-accessible path. Trusted actor verification and server operator authorization remain unimplemented. No generic backend credentials granted.

Outstanding: real two-session concurrency test, dedicated least-privileged trusted backend, eliminate/contain privileged old-path bypass, genuine JWT/RLS evidence (Issue #12), provider-supported auth schema resolution. SECURITY HOLD; PR #11 DRAFT; no production changes.
