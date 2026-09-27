# GPMS authenticated nonmember negative gate v1.1

Isolated Neon test branch only. Created synthetic Neon Auth user `gpms-outsider@example.invalid` with no memberships, created projects or owned submissions (verified zero for each). No sign-in credential or signed JWT has been issued or verified.

The JWT isolation script now requires `GPMS_TEST_JWT_OUTSIDER` from a genuine Neon Auth session. Expected response is HTTP 200 with zero visible rows for projects, submissions, submission_versions and feedback; protected audit and display tables must be denied. A 401/403 for the four readable tables is not a pass because it fails to demonstrate a valid authenticated nonmember session. Existing A/B/instructor and anonymous cases remain.

Never commit JWTs/passwords. Issue #12 remains open and SECURITY HOLD applies until signed-session tests are actually executed and independently reviewed. Production unchanged.
