# Change: Fix COMPOSE_PROFILES flags and make lifecycle scripts fail-fast

## Why
COMPOSE_PROFILES currently renders malformed `--profile` flags, breaking `make up/ps/logs` when profiles are set. The lifecycle scripts also lack fail-fast behavior, which can report success even when compose fails.

## What Changes
- Normalize `COMPOSE_PROFILES` handling so it emits only valid `--profile <name>` flags (no empty profiles or commas).
- Ensure `make up/down/logs/ps` share the same profile argument logic.
- Harden `scripts/up.sh` with a shebang and `set -euo pipefail` so failures are surfaced correctly.
- (Optional) Apply the same hardening to `scripts/down.sh` and `scripts/logs.sh` to keep behavior consistent.

## Impact
- Affected capability: `compose-wrapper`
- Affected code:
  - `Makefile`
  - `scripts/up.sh`
  - `scripts/down.sh` (optional)
  - `scripts/logs.sh` (optional)
