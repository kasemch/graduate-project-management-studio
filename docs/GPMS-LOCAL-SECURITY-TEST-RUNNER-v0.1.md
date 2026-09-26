# GPMS Local Security Test Runner — v0.1

**Preparation only; NOT EXECUTED.** The following procedure is intentionally local and destructive only to a disposable database. Do not point it at staging or production.

## Prerequisites
- Local Supabase CLI and Docker, installed by an authorized operator.
- A clean disposable database with synthetic Auth users; never use real student identities.
- Apply the base draft SQL and RPC drafts only after manual SQL review. They are deliberately not in an executable migration chain.
- Test every query using the actual actor JWT; service-role execution cannot prove RLS.

## Test fixtures
Two projects A/B, instructors IA/IB, learners A1/A2/B1; two submissions and two versions per project, plus one reviewed submission and one inactive display selection.

## Execution phases
1. **DDL smoke:** apply each draft in dependency order; fail on any SQL error. Record PostgreSQL/Supabase versions and schema diff.
2. **Privilege inventory:** inspect `pg_policies`, `information_schema.role_table_grants`, `pg_proc.proacl`, function owner, `search_path`, and default execute grants. Confirm no anonymous access and no direct privileged table mutation.
3. **Actor tests:** execute R01–R18 from the negative-test plan under each actor JWT. Record SQLSTATE and expected denial; a hidden UI is not a passing result.
4. **Transaction tests:** concurrently submit two versions; verify distinct sequential numbers, immutable prior versions, correct audit actor and approval invalidation.
5. **Instructor tests:** cross-project denial, stale version denial, inactive approval, audit entries and revocation.
6. **Projector tests:** mark BLOCKED until an authenticated redacted endpoint and session invalidation exist.
7. **Privacy:** mark BLOCKED until notice/consent, content moderation, retention and deletion requirements are approved.

## Result artifact schema
For every case: `case_id, actor, project, operation, expected, actual, sqlstate, passed, evidence_ref, reviewer, tested_at`. Missing execution evidence is `NOT_RUN`, never PASS.

## Gate
Promote drafts to ordered migrations only after DDL and all relevant negative/concurrency tests pass, independent review and explicit environment authorization. Existing GPMS Quality workflow tests the frontend build; it does not execute these SQL cases.
