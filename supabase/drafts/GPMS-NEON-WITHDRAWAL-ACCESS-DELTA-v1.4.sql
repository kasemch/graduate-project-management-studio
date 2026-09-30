-- Isolated Neon test branch only. Already applied; do not rerun without migration tracking.
ALTER POLICY gpms_submissions_owner_read ON gpms.submissions USING (owner_id=auth.uid() AND EXISTS (SELECT 1 FROM gpms.memberships m WHERE m.project_id=submissions.project_id AND m.user_id=submissions.owner_id AND m.is_active));
ALTER POLICY gpms_versions_owner_read ON gpms.submission_versions USING (EXISTS (SELECT 1 FROM gpms.submissions s JOIN gpms.memberships m ON m.project_id=s.project_id AND m.user_id=s.owner_id WHERE s.id=submission_versions.submission_id AND s.owner_id=auth.uid() AND m.is_active));
ALTER POLICY gpms_feedback_submission_owner_read ON gpms.feedback USING (EXISTS (SELECT 1 FROM gpms.submissions s JOIN gpms.memberships m ON m.project_id=s.project_id AND m.user_id=s.owner_id WHERE s.id=feedback.submission_id AND s.owner_id=auth.uid() AND m.is_active));
CREATE TABLE gpms.membership_events (id uuid PRIMARY KEY DEFAULT gen_random_uuid(),project_id uuid NOT NULL,user_id uuid NOT NULL,actor_id uuid NOT NULL,event_type text NOT NULL CHECK (event_type IN ('revoked','reactivated')),role_snapshot text NOT NULL CHECK (role_snapshot IN ('learner','instructor')),occurred_at timestamptz NOT NULL DEFAULT now(),FOREIGN KEY (project_id,user_id) REFERENCES gpms.memberships(project_id,user_id));
ALTER TABLE gpms.membership_events ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON gpms.membership_events FROM PUBLIC,anonymous,authenticated;
-- Event writes remain disabled for browser roles; trusted atomic transition and immutable enforcement are NOT implemented.
