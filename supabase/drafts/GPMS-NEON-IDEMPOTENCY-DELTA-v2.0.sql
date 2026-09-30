-- Applied ONLY to isolated gpms-security-test. Requires v1.5 membership function and event table.
-- Privileged maintenance test function, NOT an authorized endpoint. No browser grants.
CREATE TABLE gpms.membership_idempotency (
 actor_id uuid NOT NULL, project_id uuid NOT NULL,
 idempotency_key text NOT NULL CHECK(idempotency_key ~ '^[A-Za-z0-9_-]{16,128}$'),
 request_fingerprint text NOT NULL,
 event_id uuid NOT NULL REFERENCES gpms.membership_events(id),
 created_at timestamptz NOT NULL DEFAULT now(),
 PRIMARY KEY(actor_id,project_id,idempotency_key)
);
ALTER TABLE gpms.membership_idempotency ENABLE ROW LEVEL SECURITY;
CREATE FUNCTION gpms.set_membership_active_once(p_project uuid,p_user uuid,p_active boolean,p_actor uuid,p_key text)
RETURNS TABLE(event_id uuid,replayed boolean) LANGUAGE plpgsql SECURITY DEFINER SET search_path=pg_catalog,gpms AS $fn$
DECLARE v_hash text; v_old gpms.membership_idempotency%ROWTYPE; v_event uuid;
BEGIN
 IF p_project IS NULL OR p_user IS NULL OR p_active IS NULL OR p_actor IS NULL OR p_key IS NULL OR p_key !~ '^[A-Za-z0-9_-]{16,128}$' THEN RAISE EXCEPTION 'Invalid request'; END IF;
 v_hash:=md5(p_project::text||':'||p_user::text||':'||p_active::text||':'||p_actor::text);
 PERFORM pg_advisory_xact_lock(hashtextextended(p_actor::text||':'||p_project::text||':'||p_key,0));
 SELECT * INTO v_old FROM gpms.membership_idempotency WHERE actor_id=p_actor AND project_id=p_project AND idempotency_key=p_key FOR UPDATE;
 IF FOUND THEN
  IF v_old.request_fingerprint<>v_hash THEN RAISE EXCEPTION 'Idempotency conflict' USING ERRCODE='23505'; END IF;
  event_id:=v_old.event_id; replayed:=true; RETURN NEXT; RETURN;
 END IF;
 v_event:=gpms.set_membership_active(p_project,p_user,p_active,p_actor);
 INSERT INTO gpms.membership_idempotency(actor_id,project_id,idempotency_key,request_fingerprint,event_id) VALUES(p_actor,p_project,p_key,v_hash,v_event);
 event_id:=v_event; replayed:=false; RETURN NEXT;
END $fn$;
REVOKE ALL ON FUNCTION gpms.set_membership_active_once(uuid,uuid,boolean,uuid,text) FROM PUBLIC,anonymous,authenticated,gpms_app,gpms_test_reader;
