import { existsSync } from 'node:fs';
assertMigrationIsolation();
function assertMigrationIsolation() { if (existsSync('supabase/migrations/20260926_gpms_access_draft.sql')) throw new Error('Unreviewed GPMS schema must not be in migrations'); }
import { readFileSync } from 'node:fs';
import assert from 'node:assert/strict';
const base = readFileSync('supabase/drafts/gpms_access_schema_v0.1.sql','utf8');
const submission = readFileSync('supabase/drafts/gpms_trusted_submission_rpc_v0.1.sql','utf8');
const instructor = readFileSync('supabase/drafts/gpms_instructor_transactions_v0.1.sql','utf8');
const active = s => s.split('\n').filter(line => !/^\s*--/.test(line)).join('\n').toLowerCase();
const ddl = active(base), rpc = active(submission), teacher = active(instructor);
for (const table of ['projects','memberships','submissions','submission_versions','feedback','display_approvals'])
  assert.match(ddl,new RegExp('alter table public\\.gpms_'+table+' enable row level security;'));
for (const table of ['memberships','submission_versions','display_approvals','feedback','projects','submissions'])
  assert.match(ddl,new RegExp('revoke [^;]+ on public\\.gpms_'+table+' from anon,authenticated;'));
for (const table of ['memberships','submission_versions','display_approvals','feedback'])
  assert.doesNotMatch(ddl,new RegExp('create policy [^;]+ on public\\.gpms_'+table+' for (insert|update|delete) to authenticated'));
assert.doesNotMatch(ddl,/create policy [^;]+ to anon\b/);
assert.match(rpc,/for update;/);
assert.match(rpc,/coalesce\(max\(version_no\),0\)\+1/);
assert.match(rpc,/set is_active=false/);
assert.match(teacher,/values\(p_submission_id,p_version_id,v_actor,false\)/);
assert.doesNotMatch(teacher,/is_active\s*=\s*true/);
for (const text of [rpc,teacher]) {
 assert.match(text,/security definer set search_path=''/);
 assert.match(text,/revoke all on function/);
}
console.log('PASS: GPMS static SQL guardrails. NOT a SQL execution or RLS test.');
