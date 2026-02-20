## 1. Discovery
- [x] 1.1 Confirm current COMPOSE_PROFILES arg generation and how it behaves for empty/trailing commas.
- [x] 1.2 Confirm which scripts are invoked by Makefile and whether they already parse profile flags.

## 2. Implementation
- [x] 2.1 Normalize COMPOSE_PROFILES in Makefile to emit valid `--profile <name>` flags only.
  - Acceptance: no malformed flags such as `--profile --profile ,stepca` are generated.
- [x] 2.2 Update `scripts/up.sh` with a shebang and `set -euo pipefail` to fail fast.
  - Acceptance: compose failures return non-zero and do not print success.
- [x] 2.3 (Optional) Apply the same hardening to `scripts/down.sh` and `scripts/logs.sh`.
  - Acceptance: failure states return non-zero and stop execution.

## 3. Validation
- [x] 3.1 `make up` works with no profiles set.
- [x] 3.2 `COMPOSE_PROFILES=stepca make up` uses a single valid `--profile stepca` flag.
- [x] 3.3 `COMPOSE_PROFILES=le,stepca make ps` uses both profiles with no empty flags.
- [x] 3.4 `make logs` works with and without profiles and exits non-zero on failure.
