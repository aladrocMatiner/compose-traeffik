## 1. Discovery
- [x] 1.1 Confirm current Makefile `ps` target indentation and related compose wrapper usage.
- [x] 1.2 Confirm current compose wrapper behavior for project name/dir and existing env vars (`PROJECT_NAME`, `COMPOSE_PROFILES`).

## 2. Implementation
- [x] 2.1 Fix `Makefile` so `ps:` is a real target and uses the same compose invocation pattern as other targets.
  - Acceptance: `make ps` runs without errors and lists services.
- [x] 2.2 Pin compose project directory and name inside `scripts/compose.sh`.
  - Acceptance: running the wrapper from any CWD reuses the same project, networks, and volumes.
- [x] 2.3 Update Makefile to pass a stable project name consistently (or rely on wrapper default).
  - Acceptance: `make up/down/ps/logs` use a consistent project name.
- [x] 2.4 Update `.env.example` with `COMPOSE_PROJECT_NAME` if introduced (or document derivation from `PROJECT_NAME`).
  - Acceptance: new/updated var is documented with safe defaults.
- [x] 2.5 (Optional) Add a short README note explaining project pinning.
  - Acceptance: note is concise and accurate.

## 3. Validation
- [x] 3.1 Run `make ps` to confirm target works.
- [x] 3.2 Run compose commands from a different CWD to confirm project name remains stable and no new networks/volumes are created.
