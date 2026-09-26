# GPMS Security Gate Matrix v0.2 — DESIGN REVIEW

The SQL draft now **denies direct browser writes** for submission status/ownership, versions, feedback edits, membership changes and projector approvals. These operations require separately designed trusted server transactions. This is a fail-closed prototype, not a functioning submission backend.

| Boundary | Current behavior | Release requirement |
|---|---|---|
| Membership | no client insert/update/delete | admin provisioning with audited authorization |
| Submission | owner-only insert/read; no client update/delete | authenticated server RPC with immutable owner/project and legal transitions |
| Versions | owner/instructor read; no direct client insert/update/delete | append-only atomic version allocation, validated parent and actor |
| Feedback | instructor-only insert, no edit/delete | audited correction process |
| Display | read limited to owner/instructor; no client write | server approval/revoke of exact moderated version |
| Projector | no anonymous database policy | short-lived instructor-controlled redacted endpoint; stop invalidates session |
| Cross-project | RLS membership checks | negative JWT tests for every table |
| Privacy | synthetic-only | retention, notices, minimization, institutional review |

## Execution checklist (local only)
1. Start isolated local Supabase and use disposable synthetic Auth accounts.
2. Apply migration to a clean database; capture SQL errors, table grants, policies and function execution grants.
3. Provision two projects, two instructors and three learners through trusted setup only.
4. Run all R01–R18 negative cases using actor JWTs; verify explicit denial rather than merely an empty UI.
5. Verify privileged workflows are **unavailable** until trusted RPCs and audit tables are added. Do not weaken RLS to make UI work.
6. Record test outputs and reviewer sign-off before any staging proposal.

**Known limitations:** SQL has not been executed; no negative tests have passed; security-definer helpers require independent search_path and privilege review; no real student records or projector endpoint.
