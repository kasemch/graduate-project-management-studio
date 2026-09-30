# GPMS Neon security gate v0.2

Scope: isolated gpms-security-test branch only. Production unchanged.

Verified: Neon Auth Better Auth and Neon Data API are active; Data API exposes only gpms schema, with default grants disabled. Seven gpms tables have RLS enabled. Five read-only policies use auth.uid(). Anonymous role has no gpms schema access. Authenticated role has no write grants. No GPMS application rows exist.

Blocking finding: the auth schema is owned by cloud_admin, and authenticated lacks USAGE when tested via SET ROLE; an attempted GRANT from neondb_owner did not change that privilege. Do not interpret empty result sets as proof that authenticated JWT reads work. No end-to-end JWT test or learner A/B isolation test has passed.

Release gates: verify real signed Neon Auth JWT via Data API; verify auth.uid() within that request; test two synthetic learners and instructor, including cross-project denial; confirm no unauthenticated reads, writes, or audit access; only then consider narrowly scoped write paths and staging integration. No production deployment, real student data, or PR merge until gates pass.
