# GPMS role-denial result v0.8

Scope: isolated Neon `gpms-security-test` branch; synthetic fixtures only.

Actual transaction-scoped SQL role tests:
- `authenticated` INSERT into `gpms.projects`: denied, `permission denied for table projects`.
- `authenticated` UPDATE of existing synthetic project: denied, `permission denied for table projects`.
- `anonymous` SELECT from `gpms.projects`: denied, `permission denied for schema gpms`.

Privilege audit confirms all seven GPMS tables have RLS, no INSERT/UPDATE/DELETE for authenticated, and no SELECT for anonymous. Five intended read tables grant SELECT to authenticated; audit_events and display_approvals do not. These tests do not prove genuine Neon Auth JWT mapping or learner A/B isolation. Issue #12 remains open, PR #11 DRAFT, SECURITY HOLD. Do not change production or open student access.
