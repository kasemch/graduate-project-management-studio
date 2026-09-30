# GPMS synthetic negative tests v0.7

Scope: isolated Neon branch `gpms-security-test`, not production. Synthetic fixtures: 2 projects, 4 memberships, 2 submissions, 2 versions, 2 feedback. No real student data.

Executed negative cases against nonempty fixtures:
1. Insert display approval for submission A with version B: foreign-key violation caught as expected; test would have raised an uncaught exception if accepted.
2. Insert audit event for submission A with project B: foreign-key violation caught as expected; test would have raised an uncaught exception if accepted.
Post-test counts: display_approvals=0, audit_events=0. This establishes relational constraint behavior only.

Authenticated SQL role without a real signed session returned no rows for projects, submissions, versions and feedback. This does not establish JWT-based A/B isolation or instructor access. `auth` schema USAGE remains unresolved for authenticated in direct SQL role checks. Keep SECURITY HOLD. No API writes or public display enabled. PR #11 remains DRAFT.
