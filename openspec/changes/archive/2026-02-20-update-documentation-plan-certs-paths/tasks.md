## 1. Implementation
- [x] Locate `certs/` references in documentation_plan.md.
- [x] Replace `certs/` references with `shared/certs/`.
- [x] Add a short canonical-path note (CERTS_DIR = shared/certs).
- [x] Verify the TLS assets section matches current repo layout.

## 2. Decision
- [x] Decide how to handle the local untracked `certs/` directory (delete vs .gitignore). (Decision: ignore via .gitignore.)
- [x] If ignoring, plan the .gitignore update (do not implement unless approved). (Implemented: .gitignore now ignores `certs/`.)

## 3. Verification
- [x] Confirm documentation_plan.md only references shared/certs and includes the canonical note.
