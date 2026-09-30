# GPMS RLS Negative Test Plan — v0.1

Status: **NOT EXECUTED**. Use isolated local Supabase and synthetic Auth users. Do not use production credentials or student data.

Fixtures: project A and B; learner A1 and A2 in A, learner B1 in B, instructor IA in A and IB in B; each has one submission and two versions. Provision memberships with a trusted setup account only. Execute each request using the actual JWT of the indicated actor, not service-role.

| Test | Actor | Attempt | Expected |
|---|---|---|---|
| R01 | anonymous | select any table | denied |
| R02 | A1 | read A2 or B1 submission, versions, feedback | denied |
| R03 | A1 | insert submission with A2 owner or project B | denied |
| R04 | A1 | update A2 submission | denied |
| R05 | A1 | change own submission project_id/owner_id | denied |
| R06 | A1 | insert version for A2 submission | denied |
| R07 | A1 | alter/delete an existing version | denied |
| R08 | A1 | insert feedback or display approval | denied |
| R09 | IA | read B submissions or create B feedback/approval | denied |
| R10 | IA | approve version from a different submission | denied |
| R11 | A1 | add self as instructor / add another membership | denied |
| R12 | IA | approve own project submission version | allowed after content review |
| R13 | IA | revoke approval | allowed and projector snapshot invalidated |
| R14 | A1 | read projector payload directly | denied |
| R15 | IA | approve content containing identifying text | held for moderation |
| R16 | A1 | overwrite a reviewed/submitted version or edit status directly | denied |
| R17 | IA | change approval's approved_by to another user | denied |
| R18 | A1 | create versions with duplicate or non-monotonic version numbers | denied |

**Current migration is expected to fail several of these tests.** It lacks immutable field enforcement for submission updates, append-only version triggers and transaction-safe version numbering; submission state changes and projector delivery need trusted server-side functions. Do not mark the migration deployable based on frontend CI.

Release gate: automated RLS tests with explicit pass/fail evidence; audited SQL diff; authenticated server-side projector session with expiry/revocation; content redaction; browser accessibility and security testing; institutional data protection review. No real student access before all gates pass.
