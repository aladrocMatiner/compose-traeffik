- [x] Title: Define required env vars and defaults
  Files: `.env.example`, `scripts/env-generate.sh`
  Acceptance: Required vars and sane defaults are listed and documented.

- [x] Title: Implement env generation script
  Files: `scripts/env-generate.sh`
  Acceptance: Script creates `.env` from `.env.example` and fills empty secrets with secure random values.

- [x] Title: Ensure idempotency and force option
  Files: `scripts/env-generate.sh`
  Acceptance: Existing `.env` values are preserved unless `--force` is passed.

- [x] Title: Add bootstrap make target
  Files: `Makefile`
  Acceptance: `make bootstrap` runs env generation and creates required directories.

- [x] Title: Update Quickstart documentation
  Files: `README.md`
  Acceptance: Quickstart includes `make bootstrap && make up`.

- [x] Title: Verify gitignore handling
  Files: `.gitignore`
  Acceptance: `.env` is ignored and `.env.example` remains tracked.

- [x] Title: Add verification checklist
  Files: `openspec/changes/bootstrap-env-random-secrets/proposal.md`
  Acceptance: Checklist covers `.env` creation, secret length, and non-overwrite behavior.
