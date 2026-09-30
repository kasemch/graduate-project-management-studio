# GPMS Instructor Transactions — review contract v0.1

**Unexecuted draft.** The instructor functions in `supabase/drafts/gpms_instructor_transactions_v0.1.sql` are not production-ready.

- Feedback requires authenticated instructor membership for the submission's project, bounded nonempty text and an audit event.
- Display selection requires instructor membership, reviewed status and the exact latest version. Selection remains **inactive** by design: no consent/moderation or secure projector endpoint exists.
- Revoke writes an audit event and deactivates selection. It cannot itself terminate an external display session because that service has not been implemented.
- All three functions use fixed search paths and explicit execute grants, but function ownership and table privileges still require review.

## Required negative and concurrency tests
1. Learner, anonymous and cross-project instructor calls to each function are denied.
2. Approval of a version from another submission, stale version or unreviewed submission is denied.
3. New learner version and instructor approval racing on the same submission serialize safely; approval never becomes active.
4. Feedback is append-only; the audit actor and project match the authenticated instructor.
5. Revocation is idempotent and never enables a projector session.
6. Test a missing approval row, deleted version constraints, malformed input and concurrent instructor calls.
7. Validate all direct browser grants are denied and no function has unexpected PUBLIC execute privilege.

## Release blockers
Consent/notice, moderation, projector redaction, short-lived display session and revocation propagation, local Supabase execution, automated RLS evidence, and institutional review. Do not merge this draft as an operational backend or use real student records.
