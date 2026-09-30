# GPMS Idempotency & Replay Gate v1.9

Offline pure model and CI test added. Key scope is (verified actor, project, idempotency key); SHA-256 fingerprint covers actor, project, target user, requested active state. Same key + same payload replays prior result without a second operation. Same key + changed payload conflicts. Failed operation leaves no recorded success and can be retried. Separate actor has separate scope.

**Not production replay protection:** Map model has no persistence or concurrent-request coordination. The actual database design must use a unique (actor_id,project_id,idempotency_key) record with request fingerprint, result/event reference and state, inserted/locked in the same transaction as membership update and immutable event. Concurrent identical requests must serialize; different payloads conflict. Failed transaction must not leave success marker or partial membership change. Do not trust caller-supplied actor ID or store JWT/secret in ledger. Operator role provisioning and real JWT verification are pending.

PR #11 DRAFT, SECURITY HOLD, no production or student data. Issue #12 remains prerequisite.
