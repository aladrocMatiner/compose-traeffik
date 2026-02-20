## 1. Discovery
- [x] 1.1 Confirm current bootstrap flow, variables, and failure points in `scripts/stepca-bootstrap.sh`.
- [x] 1.2 Confirm current step-ca env and volumes in `services/step-ca/compose.yml` and `.env.example`.

## 2. Implementation
- [x] 2.1 Make `stepca-bootstrap.sh` fail-fast (`set -euo pipefail`) and exit non-zero on any failed init step.
  - Acceptance: script exits with non-zero and a clear error message on failures.
- [x] 2.2 Switch to a non-interactive init path (use supported DOCKER_STEPCA_INIT_* env or explicit password files).
  - Acceptance: bootstrap succeeds without TTY interaction and does not hang in `docker exec`.
- [x] 2.3 Gate `--ssh` generation behind an explicit env flag (default off) or remove it if not required.
  - Acceptance: no SSH template file dependency unless explicitly enabled.
- [x] 2.4 Validate/derive `STEP_CA_DNS` and fail if empty; document defaults in `.env.example`.
  - Acceptance: SAN list is never empty and bootstrap fails if unable to derive.
- [x] 2.5 Add post-init verification output (ACME URL, CA cert path, one verification command) only after successful init.
  - Acceptance: no success messages printed when init fails.

## 3. Validation
- [x] 3.1 Fresh bootstrap succeeds non-interactively or exits non-zero with a clear reason.
- [x] 3.2 Missing `STEP_CA_DNS` produces a deterministic, non-empty derived list or fails fast with guidance.
- [x] 3.3 Verification output matches actual paths/URLs after success.
