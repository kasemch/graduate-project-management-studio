# GPMS atomic membership test v1.5

Isolated Neon test branch only. Maintenance-only SECURITY DEFINER function updates membership and inserts event in one transaction, locking membership row. EXECUTE revoked from PUBLIC, anonymous, authenticated, gpms_app, gpms_test_reader. This is **not an authorized public API**: caller identity/actor binding and operator authorization are not yet implemented.

Synthetic learner A: revoke and reactivate succeeded, retaining membership and submissions. Two additional transitions succeeded after immutable trigger was installed. Four event rows retained; membership returned active. UPDATE and DELETE of event rows rejected with 'Membership events are immutable'; no-op transition rejected and event count stayed unchanged. This confirms tested database behavior, not JWT/RLS execution. Table owner/superuser can still modify DDL; database trigger alone is not tamper-proof against administrators.

Outstanding: explicit authorized actor model, forced failure injection proving atomic rollback, real JWT read isolation, retention policy and operational backup. SECURITY HOLD; no production changes.
