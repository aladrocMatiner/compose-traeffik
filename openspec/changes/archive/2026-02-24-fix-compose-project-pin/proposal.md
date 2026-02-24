# Change: Fix Makefile ps target and pin compose project name/directory

## Why
`make ps` is currently not a valid target due to indentation, and `scripts/compose.sh` does not pin the compose project name or directory, which leads to cross-CWD project/volume/network conflicts.

## What Changes
- Fix `make ps` to be a proper target and keep it aligned with existing compose wrapper usage.
- Make `scripts/compose.sh` deterministic by pinning `--project-directory` and a stable `--project-name` derived from env (`COMPOSE_PROJECT_NAME` or `PROJECT_NAME`) with a safe fallback.
- Update Makefile to pass through the project name consistently.
- (Optional) Add a short README note explaining project pinning if needed.

## Impact
- Affected capability: `compose-wrapper`
- Affected code:
  - `Makefile`
  - `scripts/compose.sh`
  - `.env.example` (if adding `COMPOSE_PROJECT_NAME` or documenting behavior)
  - `README.md` (optional note)

