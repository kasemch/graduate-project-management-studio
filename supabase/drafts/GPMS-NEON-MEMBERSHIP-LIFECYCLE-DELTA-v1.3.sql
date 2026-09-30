-- ISOLATED NEON BRANCH ONLY: gpms-security-test. NOT a production migration.
-- Retain membership history while revoking active access. Applied and tested 2026-09-29.
ALTER TABLE gpms.memberships
  ADD COLUMN is_active boolean NOT NULL DEFAULT true,
  ADD COLUMN revoked_at timestamptz,
  ADD CONSTRAINT memberships_revocation_consistency CHECK
    ((is_active AND revoked_at IS NULL) OR (NOT is_active AND revoked_at IS NOT NULL));
ALTER POLICY gpms_projects_member_read ON gpms.projects USING
  (EXISTS (SELECT 1 FROM gpms.memberships m WHERE m.project_id=projects.id AND m.user_id=auth.uid() AND m.is_active));
ALTER POLICY gpms_submissions_instructor_read ON gpms.submissions USING
  (EXISTS (SELECT 1 FROM gpms.memberships m WHERE m.project_id=submissions.project_id AND m.user_id=auth.uid() AND m.role='instructor' AND m.is_active));
ALTER POLICY gpms_versions_instructor_read ON gpms.submission_versions USING
  (EXISTS (SELECT 1 FROM gpms.submissions s JOIN gpms.memberships m ON m.project_id=s.project_id WHERE s.id=submission_versions.submission_id AND m.user_id=auth.uid() AND m.role='instructor' AND m.is_active));
ALTER POLICY gpms_feedback_instructor_read ON gpms.feedback USING
  (EXISTS (SELECT 1 FROM gpms.submissions s JOIN gpms.memberships m ON m.project_id=s.project_id WHERE s.id=feedback.submission_id AND m.user_id=auth.uid() AND m.role='instructor' AND m.is_active));
-- Creator-only project access bypassed membership revocation; remove it.
DROP POLICY gpms_projects_creator_read ON gpms.projects;
-- Ownership policies on submissions/versions/feedback remain; historical owner access
-- needs separate retention/privacy decision. Membership self-read retains historical rows.
-- Do not use unrestricted direct UPDATE in the student API; current role has SELECT only.
