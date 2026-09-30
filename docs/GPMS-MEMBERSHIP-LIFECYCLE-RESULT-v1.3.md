# GPMS Membership Lifecycle v1.3 — isolated Neon branch

Implemented on `gpms-security-test` only. Added `is_active` and `revoked_at` with consistency CHECK; instructor and member read policies now require active membership. Removed creator-only project read policy that would bypass revocation. Historical membership row is retained, not deleted. No browser write grants were added.

Synthetic test: revoked instructor membership in project A, observed one active instructor membership remaining out of two retained; two submissions retained. Restored project A membership to active after test. This is a structural/data test, **not** genuine JWT RLS validation.

Remaining design gate: owner read policies still allow historical owner to read own submission/version/feedback even after membership revocation. Decide whether alumni/withdrawn learners retain access; do not silently revoke or expose historical records. Instructor audit attribution and append-only revocation events need server-side trusted transaction before production. JWT/RLS Issue #12 remains open. SECURITY HOLD.
