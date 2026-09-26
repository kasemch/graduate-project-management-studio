# GPMS Access & Data Architecture — staging design v0.1

**Status:** draft, unexecuted. No production connection or student data. SQL is a review baseline, not a certified security implementation.

## Roles and boundaries
- Learner: read own submissions/versions/feedback, create own submissions and versions. No instructor role or approval writes.
- Instructor: read project submissions and versions, create feedback, approve an exact version for display, revoke approval.
- Projector: no direct database or anonymous read. An authenticated, instructor-controlled server endpoint must emit only a redacted, approved snapshot; stop must revoke the server-side session and invalidate any cached snapshot.
- Membership assignment and project creation must be provisioned through a trusted administrative workflow, never directly from browser credentials.

## Security gates before staging execution
1. Review migration for RLS, grants, constraints, update paths and ownership; test with two projects, two learners and one instructor, including cross-project access.
2. Add immutable-version enforcement, monotonic version assignment and transaction-safe submission state transitions on the server. Do not rely on client-side counters.
3. Ensure feedback and approvals have append-only audit events; verify approval version belongs to submission and revocation propagates immediately.
4. Build server-only instructor/projector session authorization. Never expose service-role keys in Vite frontend.
5. Set retention, consent/notice, deletion and export policies; avoid student names on projected content and check content for identifying text.
6. Run migration in isolated local Supabase first, with synthetic fixtures and automated negative permission tests. Staging deployment needs explicit environment and cost review.

## Existing frontend limitations
Evidence Center's learner/instructor buttons are a visual simulation, not an access control boundary. JSON export is local only. Current SQL does not implement project provisioning, storage buckets, moderation, projector delivery, or complete audit retention. Do not enable real submissions until these are implemented and independently verified.
