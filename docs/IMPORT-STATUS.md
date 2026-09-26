# GPMS source provenance and import status

Updated 2026-09-26.

- The original UI-05 archive was not imported byte-for-byte.
- A newly authored React/TypeScript/Vite demonstration prototype was committed to `develop` instead.
- The repository contains `src/main.tsx`, `src/modules.tsx`, `src/style.css`, application configuration, source check and CI workflow.
- Twelve navigation modules are represented, but several share generic demonstration tables. This is **PARTIAL**, not feature-complete.
- The original UI-05 archive and the repository version must not be described as identical.
- Build and browser QA: NOT VERIFIED; consult QA-REPORT.md.
- Data persistence: in-memory only; JSON export is available for selected content.
- Real student data, merge to main and public deployment: HOLD.

Next: execute build/CI, fix verified errors, test browser responsiveness and seek human release authorization.
