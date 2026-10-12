# GPMS Repository Overlay — GitHub Copilot Faculty Engineering Standard v1.0

Status: CONTROLLED ROLLOUT CANDIDATE / MERGE HOLD

## Baseline
Repository: `kasemch/graduate-project-management-studio`
Verified rollout base: `main` at `2a99113adb13430a0055632d4f149a6fc1cf1b1d`.
Architecture: React 18 + TypeScript + Vite 6 static application.
Existing quality gate: `.github/workflows/quality.yml`.
Existing production path: `.github/workflows/deploy-pages.yml`, triggered by push to `main`.

## Change classification
This rollout is C0 governance-only. It adds agent instructions and repository governance documentation. It must not change application runtime, UI, source modules, package dependencies, data, or production deployment behavior.

## Repository-specific authority
`docs/RELEASE-GATE.md` remains authoritative and is not weakened by this overlay. Safe reversible development can proceed without routine approval, but merge to `main` for release/publication remains a Human Gate.

## Required validation
- Existing `GPMS quality` workflow must succeed on the exact PR head.
- Changed-file review must confirm only governance/instruction files were added.
- Existing `deploy-pages.yml` must remain unchanged.
- No dependency/package/source/runtime/data changes are permitted in this rollout.
- No secrets or private student/personal data may be introduced.

## Rollback
Close the rollout PR and delete the rollout branch. Until the Human Gate is approved, `main` and the production site remain unchanged.

## Adjudication rule
PASS requires exact-head CI success plus diff/scope/privacy review. PASS does not itself authorize merge or production deployment.
