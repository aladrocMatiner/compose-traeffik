# Change: Update Documentation Plan Cert Paths

## Summary
Align `documentation_plan.md` with the canonical certificate path `shared/certs/` and record the canonical path to prevent regressions.

## Problem
`documentation_plan.md` still references `certs/`, while the repository now uses `shared/certs/`. This mismatch can reintroduce outdated paths in future docs.

## Goals
- Replace `certs/` references with `shared/certs/` in the documentation plan.
- Add a short note declaring the canonical cert path (`CERTS_DIR = shared/certs/`).
- Decide how to handle the untracked local `certs/` directory (delete or ignore), without implementing that change yet.

## Non-goals
- No edits outside `documentation_plan.md` during this change unless explicitly approved.
- No refactors of documentation structure beyond path alignment.

## Approach
- Update `documentation_plan.md` references from `certs/` to `shared/certs/`.
- Add a short note indicating the canonical cert path (`CERTS_DIR = shared/certs/`).
- Add a task to decide how to handle the local untracked `certs/` directory (remove or ignore via `.gitignore`).

## Affected files
- `documentation_plan.md` (apply stage)
- `.gitignore` (only if the decision is to ignore `certs/`)

## Verification
- `documentation_plan.md` references only `shared/certs/`.
- The canonical path note exists and is easy to find.
