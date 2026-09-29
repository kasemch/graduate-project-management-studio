// Offline regression test: reject malicious or malformed URLs before any JWT-bearing request.
import { spawnSync } from 'node:child_process';
const exact = 'https://ep-cool-firefly-b3fxs2b4.apirest.c-4.ap-southeast-1.aws.neon.tech/neondb/rest/v1';
const bad = [
  exact.replace('.neon.tech/', '.neon.tech.evil.example/'),
  exact.replace('https://', 'http://'),
  exact.replace('/neondb/rest/v1', '/neondb/rest/v1/extra'),
  exact + '?redirect=1', exact + '#fragment',
  exact.replace('https://', 'https://user:secret@'),
  exact.replace('.neon.tech/', '.neon.tech:8443/')
];
for (const script of ['gpms-neon-jwt-read-gate.mjs','gpms-neon-jwt-isolation-gate-v2.mjs']) {
  for (const url of bad) {
    const result = spawnSync(process.execPath, [new URL(script, import.meta.url).pathname], {
      env: { ...process.env, GPMS_TEST_API_URL:url, GPMS_TEST_JWT_A:'dummy-a', GPMS_TEST_JWT_B:'dummy-b', GPMS_TEST_JWT_INSTRUCTOR:'dummy-instructor', GPMS_TEST_JWT_OUTSIDER:'dummy-outsider' },
      encoding:'utf8', timeout:5000
    });
    if (result.status === 0 || !(result.stderr + result.stdout).includes('Refusing non-isolated test API target')) {
      throw new Error('Unsafe target was not rejected before fetch: ' + script);
    }
  }
  console.log('PASS offline exact-origin rejection: ' + script + ' (' + bad.length + ' invalid URLs)');
}
