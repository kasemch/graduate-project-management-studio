import {readFileSync,existsSync} from 'node:fs';
const required=['index.html','package.json','vite.config.ts','src/main.tsx','src/modules.tsx','src/style.css','.github/workflows/quality.yml'];
for(const f of required){if(!existsSync(f))throw Error(`Missing ${f}`)}
const app=readFileSync('src/main.tsx','utf8');
for(const m of ['Dashboard','Project Explorer','Project Overview','Proposal Builder','Planning & Gantt','Budget Management','Team & Tasks','Implementation','Evaluation Studio','Evidence Center','Report Studio','Learning Workspace'])if(!app.includes(m))throw Error(`Missing navigation: ${m}`);
if(!app.includes('SYNTHETIC DEMO'))throw Error('Missing synthetic data warning');
console.log('Source structure PASS: 12 navigation labels, required files, synthetic warning');
