-- Applied and tested ONLY on isolated Neon branch gpms-security-test.
-- Not a production migration or a Supabase migration.
-- Prevent a submission owner from belonging to a different project or no project.
ALTER TABLE gpms.submissions
  ADD CONSTRAINT submissions_owner_is_project_member
  FOREIGN KEY (project_id, owner_id)
  REFERENCES gpms.memberships(project_id, user_id);
-- Negative tests: learner B / unrelated user as owner of project A rejected.
-- Existing synthetic submissions remained 2; rejected test rows remained 0.
-- Membership deletion is restricted while owned submissions reference it;
-- design retention/withdrawal workflow before real onboarding.
