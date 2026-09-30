# GPMS Neon Data API hardening v0.4

Target: gpms-security-test only. Verified Data API settings: db_schemas=[gpms], db_aggregates_enabled=false, db_max_rows=50, openapi_mode=disabled. Neon Auth remains enabled. No production changes.

Seven GPMS tables have RLS. Authenticated has SELECT only on five tables; anonymous has no schema access. No write access granted to API roles. Existing read policies are preliminary and do not establish instructor/project membership access. They must be reviewed before release.

Known blocker: auth schema is owned by cloud_admin and authenticated lacks schema USAGE in direct SQL role tests. A real signed JWT through Data API has not yet been tested. Do not forge JWT or treat SET ROLE as equivalent to an authenticated request.

Next acceptance evidence: genuine synthetic Neon Auth sign-in, verified JWT, user A/B isolation, instructor access, denial of unauthorized writes, cross-project denial, immutable audit behavior, and public display remaining inactive. Keep SECURITY HOLD until recorded tests pass.
