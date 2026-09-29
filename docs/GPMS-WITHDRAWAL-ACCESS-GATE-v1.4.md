# GPMS withdrawal access gate v1.4

Applied on isolated Neon branch only. Submission, version and feedback owner SELECT policies now require active membership in the submission project. Instructor access was already active-membership gated. Revoked memberships and submissions remain retained; membership self-read remains available for status display. No public access to event records.

Created `gpms.membership_events` with role snapshot, actor and timestamp; RLS enabled, no browser grants. **This is a restricted event schema, not an operational append-only audit system.** Trusted atomic transition, authorization of actor, immutable enforcement, role history and real JWT RLS tests are still pending. An exploratory synthetic event was removed because it did not correspond to an actual transition. Current fixture count: 4 memberships, 2 submissions, 2 versions, 2 feedback; event table empty.

Policy decision for pilot: withdrawn learner loses direct read access to own submission/version/feedback, but records are retained for authorized institutional review. Must confirm institutional retention/privacy policy before real deployment. SECURITY HOLD. Production untouched.
