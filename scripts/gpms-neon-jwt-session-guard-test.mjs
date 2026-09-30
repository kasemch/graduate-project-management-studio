// Offline test: repeated session credentials must fail before any network request.
import { spawnSync } from 'node:child_process';
const api='https://ep-cool-firefly-b3fxs2b4.apirest.c-4.ap-southeast-1.aws.neon.tech/neondb/rest/v1';
const r=spawnSync(process.execPath,[new URL('gpms-neon-jwt-isolation-gate-v2.mjs',import.meta.url).pathname],{env:{...process.env,GPMS_TEST_API_URL:api,GPMS_TEST_JWT_A:'same-dummy',GPMS_TEST_JWT_B:'same-dummy',GPMS_TEST_JWT_INSTRUCTOR:'third-dummy',GPMS_TEST_JWT_OUTSIDER:'fourth-dummy'},encoding:'utf8',timeout:5000});
if(r.status===0 || !(r.stderr+r.stdout).includes('Distinct user sessions required'))throw Error('Duplicate sessions were not rejected before network request');
console.log('PASS offline duplicate-session rejection');
