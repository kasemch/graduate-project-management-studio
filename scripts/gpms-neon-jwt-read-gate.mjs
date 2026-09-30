// Isolated GPMS Neon Data API security gate. Never run against production.
// Required environment: GPMS_TEST_API_URL, GPMS_TEST_JWT_A, GPMS_TEST_JWT_B,
// GPMS_TEST_JWT_INSTRUCTOR. All must be genuine Neon Auth signed session tokens.
// Read-only GET requests. Does not log tokens or user data.
const api = process.env.GPMS_TEST_API_URL;
const tokens = { a: process.env.GPMS_TEST_JWT_A, b: process.env.GPMS_TEST_JWT_B, instructor: process.env.GPMS_TEST_JWT_INSTRUCTOR };
const expected = {
  a: { projects: ['11111111-1111-4111-8111-111111111101'], submissions: ['22222222-2222-4222-8222-222222222201'] },
  b: { projects: ['11111111-1111-4111-8111-111111111102'], submissions: ['22222222-2222-4222-8222-222222222202'] },
  instructor: { projects: ['11111111-1111-4111-8111-111111111101','11111111-1111-4111-8111-111111111102'], submissions: ['22222222-2222-4222-8222-222222222201','22222222-2222-4222-8222-222222222202'] }
};
if (!api || Object.values(tokens).some(v => !v)) throw new Error('Missing test API URL or genuine test session JWT');
const u = new URL(api);
if (u.protocol !== 'https:' || u.hostname !== 'ep-cool-firefly-b3fxs2b4.apirest.c-4.ap-southeast-1.aws.neon.tech' || u.port || u.username || u.password || u.pathname !== '/neondb/rest/v1' || u.search || u.hash) throw new Error('Refusing non-isolated test API target');
async function read(table, token) {
  const res = await fetch(u.origin + u.pathname + '/' + table + '?select=id', { headers: { Authorization: 'Bearer ' + token, Accept: 'application/json' }, redirect: 'error' });
  if (!res.ok) throw new Error(table + ' returned HTTP ' + res.status);
  const rows = await res.json();
  if (!Array.isArray(rows)) throw new Error(table + ' did not return an array');
  return rows.map(row => row.id).sort();
}
let failed = false;
for (const [role, token] of Object.entries(tokens)) {
  for (const table of ['projects','submissions']) {
    try {
      const actual = await read(table, token);
      const want = [...expected[role][table]].sort();
      const pass = JSON.stringify(actual) === JSON.stringify(want);
      console.log((pass ? 'PASS' : 'FAIL') + ' ' + role + '/' + table + ' exact visible IDs');
      if (!pass) failed = true;
    } catch (err) { failed = true; console.error('FAIL ' + role + '/' + table + ': ' + err.message); }
  }
}
if (failed) process.exitCode = 1;
