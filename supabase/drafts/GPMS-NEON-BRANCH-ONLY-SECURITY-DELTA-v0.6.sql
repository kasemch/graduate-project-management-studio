-- GPMS v0.6: RECORD OF TEST-BRANCH DELTA, NOT A DEPLOYMENT MIGRATION.
-- Applied only to Neon branch gpms-security-test. DO NOT execute on production or Supabase.
-- Existing tables and prerequisite policies are required. Do not rerun blindly.

ALTER TABLE gpms.submission_versions ADD CONSTRAINT submission_versions_submission_id_id_unique UNIQUE (submission_id,id);
ALTER TABLE gpms.display_approvals ADD CONSTRAINT display_approvals_version_same_submission FOREIGN KEY (submission_id,approved_version_id) REFERENCES gpms.submission_versions(submission_id,id);
ALTER TABLE gpms.submissions ADD CONSTRAINT submissions_id_project_id_unique UNIQUE (id,project_id);
ALTER TABLE gpms.audit_events ADD CONSTRAINT audit_events_submission_same_project FOREIGN KEY (submission_id,project_id) REFERENCES gpms.submissions(id,project_id);
ALTER TABLE gpms.audit_events ADD CONSTRAINT audit_events_version_same_submission FOREIGN KEY (submission_id,version_id) REFERENCES gpms.submission_versions(submission_id,id);

CREATE POLICY gpms_projects_member_read ON gpms.projects FOR SELECT TO authenticated USING (EXISTS (SELECT 1 FROM gpms.memberships m WHERE m.project_id=projects.id AND m.user_id=auth.uid()));
CREATE POLICY gpms_submissions_instructor_read ON gpms.submissions FOR SELECT TO authenticated USING (EXISTS (SELECT 1 FROM gpms.memberships m WHERE m.project_id=submissions.project_id AND m.user_id=auth.uid() AND m.role='instructor'));
CREATE POLICY gpms_versions_instructor_read ON gpms.submission_versions FOR SELECT TO authenticated USING (EXISTS (SELECT 1 FROM gpms.submissions s JOIN gpms.memberships m ON m.project_id=s.project_id WHERE s.id=submission_versions.submission_id AND m.user_id=auth.uid() AND m.role='instructor'));
CREATE POLICY gpms_feedback_instructor_read ON gpms.feedback FOR SELECT TO authenticated USING (EXISTS (SELECT 1 FROM gpms.submissions s JOIN gpms.memberships m ON m.project_id=s.project_id WHERE s.id=feedback.submission_id AND m.user_id=auth.uid() AND m.role='instructor'));

-- API configuration is managed through Neon, not SQL: gpms schema only, aggregates off,
-- maximum rows 50, OpenAPI disabled. No API writes granted.
-- SECURITY HOLD: auth schema USAGE/JWT verification and nonempty A/B isolation tests pending.
