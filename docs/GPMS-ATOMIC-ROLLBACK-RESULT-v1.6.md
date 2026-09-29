# GPMS Atomic Rollback Result v1.6 — 2026-09-29

Isolated Neon branch `gpms-security-test` only; synthetic learner A, project A. CI run 36519033299 completed success for previous commit.

Baseline: membership active, 4 event rows. Test 1 called the transition then deliberately raised an exception inside a PL/pgSQL subtransaction; afterwards membership remained active and events remained 4. Test 2 temporarily added a CHECK rejecting 'revoked' events, invoked the transition, and caught the CHECK violation. The preceding membership UPDATE was rolled back; membership remained active, events remained 4, temporary CHECK did not persist. No production or real student data touched.

Browser roles still have no EXECUTE on maintenance function. This validates SQL atomicity under tested failures, not authorization of the actor or genuine JWT RLS. SECURITY HOLD remains. Next: trusted server identity binding, approved operator policy, real signed JWT read matrix, and retention governance.
