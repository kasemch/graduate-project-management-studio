-- Isolated gpms-security-test branch only; already applied, not idempotent migration.
-- Privileged maintenance-only function; no browser EXECUTE grant. Caller authorization
-- and trusted actor binding MUST be implemented before exposing to any API.
CREATE OR REPLACE FUNCTION gpms.set_membership_active(p_project uuid,p_user uuid,p_active boolean,p_actor uuid) RETURNS uuid LANGUAGE plpgsql SECURITY DEFINER SET search_path=pg_catalog,gpms AS $fn$
DECLARE v_role text; v_current boolean; v_id uuid;
BEGIN
 IF p_actor IS NULL OR p_user IS NULL OR p_project IS NULL OR p_active IS NULL THEN RAISE EXCEPTION 'Required membership transition argument missing'; END IF;
 SELECT role,is_active INTO v_role,v_current FROM gpms.memberships WHERE project_id=p_project AND user_id=p_user FOR UPDATE;
 IF NOT FOUND THEN RAISE EXCEPTION 'Membership not found'; END IF;
 IF v_current=p_active THEN RAISE EXCEPTION 'No-op membership transition'; END IF;
 UPDATE gpms.memberships SET is_active=p_active,revoked_at=CASE WHEN p_active THEN NULL ELSE clock_timestamp() END WHERE project_id=p_project AND user_id=p_user;
 INSERT INTO gpms.membership_events(project_id,user_id,actor_id,event_type,role_snapshot) VALUES(p_project,p_user,p_actor,CASE WHEN p_active THEN 'reactivated' ELSE 'revoked' END,v_role) RETURNING id INTO v_id;
 RETURN v_id;
END $fn$;
REVOKE ALL ON FUNCTION gpms.set_membership_active(uuid,uuid,boolean,uuid) FROM PUBLIC,anonymous,authenticated,gpms_app,gpms_test_reader;
CREATE OR REPLACE FUNCTION gpms.membership_events_immutable() RETURNS trigger LANGUAGE plpgsql SET search_path=pg_catalog AS $fn$ BEGIN RAISE EXCEPTION 'Membership events are immutable'; END $fn$;
CREATE TRIGGER membership_events_no_change BEFORE UPDATE OR DELETE ON gpms.membership_events FOR EACH ROW EXECUTE FUNCTION gpms.membership_events_immutable();
