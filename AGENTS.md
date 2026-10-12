# Agent Governance — Graduate Project Management Studio

All coding agents must follow `.github/copilot-instructions.md` and preserve stricter repository controls, especially `docs/RELEASE-GATE.md`.

Before editing, inspect relevant repository context and classify the requested change. Use the smallest coherent reversible change. Do not redesign approved UI or academic/evidence behavior unless explicitly authorized.

Never commit secrets or raw private student/personal data. Never weaken source checks, build checks, CI, privacy/security controls, or release gates to obtain a passing result. Do not claim verification without inspectable evidence.

For behavior-changing work, run repository-native validation and require exact-head GitHub Actions evidence before PASS. Stop at the Human Gates defined in `.github/copilot-instructions.md` and `docs/RELEASE-GATE.md`.
