# GitHub Copilot Instructions — Graduate Project Management Studio

This repository adopts GitHub Copilot Faculty Engineering Standard v1.0 with the repository-specific controls below.

## Repository mission
Maintain the Graduate Project Management Studio as an evidence-aware academic project-management application. Preserve the existing React/Vite architecture and approved academic/evidence behavior unless a task explicitly authorizes a change.

## Required context before editing
Inspect, as applicable:
- `README.md`
- `docs/RELEASE-GATE.md`
- `docs/STATUS.md`
- `docs/QA-REPORT.md`
- `docs/IMPORT-STATUS.md`
- `docs/ACTIVE-LEARNING-CONTENT-STANDARD-v1.md`
- `.github/workflows/quality.yml`
- `.github/workflows/deploy-pages.yml`
- `package.json`
- affected source files and `scripts/source-check.mjs`

## Governance
- Evidence-First: do not promote NOT VERIFIED, synthetic, inferred, proposed, or mock information to verified fact without admissible evidence.
- Preserve existing UI, academic content, evidence logic, data contracts, and deployment behavior unless explicitly in scope.
- Prefer minimal reversible changes on controlled branches/PRs.
- Do not weaken `scripts/source-check.mjs`, `quality.yml`, TypeScript/build checks, or release gates to make a change pass.
- Do not commit secrets, credentials, tokens, raw private student/personal data, or unnecessary personal information.
- No new dependency, framework, backend, database, auth provider, or external service unless explicitly justified and approved for the task.

## Required validation
For implementation changes, use repository-native checks:
1. `node --check scripts/source-check.mjs`
2. `node scripts/source-check.mjs`
3. `npm install --no-audit --no-fund` when dependencies are required for the check
4. `npm run build`
5. verify `dist/index.html` exists and is non-empty
6. GitHub Actions `GPMS quality` on the exact PR head SHA

## Human Gates
Explicit approval is required before:
- merge into `main` for release;
- public production deployment/publication;
- production-system connection or real student/personal-data import;
- destructive/irreversible operations or paid spending;
- institutional or academic-authority decisions.

The `develop`/controlled-branch workflow may proceed autonomously for safe, reversible development as permitted by `docs/RELEASE-GATE.md`.

## Definition of Done
Do not claim PASS merely because code was written. PASS requires applicable repository-native checks, exact-head CI evidence, scope review, privacy/security review, documented risks/rollback, and satisfaction of any Human Gate.
