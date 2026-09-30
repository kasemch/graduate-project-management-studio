# GPMS Neon Auth integration v0.1

Status: design only. Target: isolated gpms-security-test branch, not production.

Verified: PostgreSQL 18.6; Neon Auth Better Auth is enabled. The live user table is neon_auth."user" with UUID id. The database owner bypasses RLS, so authorization tests must use a restricted application role. The Supabase-specific auth.uid() and auth.users references must not be deployed unchanged.

Plan: use verified Neon Auth identity via a trusted request path; define project-scoped membership independently of login identity; prepare a separate Neon migration; test anonymous, two learners, and an instructor with synthetic records; verify cross-project denial, immutable audit, atomic version creation, and inactive display approval. Keep public display, production deployment, and real student data on hold until actual security tests pass.
