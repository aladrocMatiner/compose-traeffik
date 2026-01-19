# Change: Fix Documentation Plan Cert Path Leftovers

## Summary
Align leftover cert paths in `documentation_plan.md` with the canonical `shared/certs/` location and record the canonical path to prevent regressions.

## Problem
`documentation_plan.md` still mentions `certs/local-ca/ca.crt` in a couple of spots, while the repo’s canonical path is `shared/certs/`. This can reintroduce outdated paths in future documentation work.

## Goals
- Replace `certs/local-ca/ca.crt` with the canonical `shared/certs/...` path in `documentation_plan.md`.
- Add a short canonical-path note to the documentation plan.
- Keep the change focused on the plan document only.

## Non-goals
- No changes to historical OpenSpec proposals (e.g., older changes may still mention `certs/`).
- No edits outside `documentation_plan.md` in apply stage.

## Approach
- Replace the `certs/local-ca/ca.crt` references in `documentation_plan.md` with the canonical path already used in TLS/runtime docs (`shared/certs/local-ca/ca.crt`).
- Add a short note: “Ruta canónica de certs: shared/certs/ (CERTS_DIR)”.
- Note: There are historical references to `certs/` in older OpenSpec proposals (e.g., `openspec/changes/refactor-services-layout/proposal.md`); these remain untouched and are treated as historical context. The current source of truth is runtime/docs.

## Affected files
- `documentation_plan.md`

## Verification
- `documentation_plan.md` no longer contains `certs/local-ca/ca.crt`.
- `documentation_plan.md` explicitly mentions `shared/certs/` as the canonical path.
