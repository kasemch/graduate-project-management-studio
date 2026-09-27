// GPMS isolated-branch, read-only real-JWT isolation checks. No token is logged.
// Supply genuine Neon Auth signed JWTs via environment only. Never use production.
const base = process.env.GPMS_TEST_API_URL;
const jwt = { A: process.env.GPMS_TEST_JWT_A, B: process.env.GPMS_TEST_JWT_B, instructor: process.env.GPMS_TEST_JWT_INSTRUCTOR, outsider: process.env.GPMS_TEST_JWT_OUTSIDER };
if (!base || Object.values(jwt).some(x => !x)) throw Error('Genuine signed test JWTs and API URL required');
const target = new URL(base);
if (target.protocol !== 'https:' || target.hostname !== 'ep-cool-firefly-b3fxs2b4.apirest.c-4.ap-southeast-1.aws.neon.tech' || target.port || target.username || target.password || target.pathname !== '/neondb/rest/v1' || target.search || target.hash) throw new Error('Refusing non-isolated test API target');
const ids = { A: ['11111111-1111-4111-8111-111111111101','22222222-2222-4222-8222-222222222201','33333333-3333-4333-8333-333333333301','44444444-4444-4444-8444-444444444401'], B: ['11111111-1111-4111-8111-111111111102','22222222-2222-4222-8222-222222222202','33333333-3333-4333-8333-333333333302','44444444-4444-4444-8444-444444444402'] };
const tables = ['projects','submissions','submission_versions','feedback'];
let failures = 0;
async function request(table, token) {
  const response = await fetch(target.origin + target.pathname + '/' + table + '?select=id', {headers: token ? {Authorization:'Bearer '+token,Accept:'application/json'} : {Accept:'application/json'}, redirect:'error'});
  if (!response.ok) return {status:response.status};
  const rows = await response.json();
  if (!Array.isArray(rows)) throw Error('Unexpected response type');
  return {status:response.status, ids:rows.map(r=>r.id).sort()};
}
for (const [who,token] of Object.entries(jwt)) {
  for (let i=0;i<tables.length;i++) {
    try {
      const got = await request(tables[i],token);
      const want = who==='instructor' ? [ids.A[i],ids.B[i]].sort() : who==='outsider' ? [] : [ids[who][i]];
      const ok = got.status===200 && JSON.stringify(got.ids)===JSON.stringify(want);
      console.log((ok?'PASS':'FAIL')+' '+who+' '+tables[i]+' exact visibility');
      if (!ok) failures++;
    } catch(e) { console.error('FAIL '+who+' '+tables[i]+' '+e.message); failures++; }
  }
  for (const table of ['display_approvals','audit_events']) {
    try {const got=await request(table,token);const ok=got.status===401||got.status===403;console.log((ok?'PASS':'FAIL')+' '+who+' '+table+' denied');if(!ok)failures++;}
    catch(e){console.error('FAIL '+who+' '+table+' '+e.message);failures++;}
  }
}
for (const table of [...tables,'memberships','display_approvals','audit_events']) {
  try {const got=await request(table,null);const ok=got.status===401||got.status===403;console.log((ok?'PASS':'FAIL')+' anonymous '+table+' denied');if(!ok)failures++;}
  catch(e){console.error('FAIL anonymous '+table+' '+e.message);failures++;}
}
if(failures) {console.error('Security gate failed: '+failures+' checks');process.exitCode=1;} else console.log('Read isolation gate PASS; write gates and email verification remain separate.');
