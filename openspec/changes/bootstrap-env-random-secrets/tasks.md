1. Title: Define required env vars and defaults
   Files: `.env.example`, `scripts/env-generate.sh`
   Acceptance: Required vars and sane defaults are listed and documented.

2. Title: Implement env generation script
   Files: `scripts/env-generate.sh`
   Acceptance: Script creates `.env` from `.env.example` and fills empty secrets with secure random values.

3. Title: Ensure idempotency and force option
   Files: `scripts/env-generate.sh`
   Acceptance: Existing `.env` values are preserved unless `--force` is passed.

4. Title: Add bootstrap make target
   Files: `Makefile`
   Acceptance: `make bootstrap` runs env generation and creates required directories.

5. Title: Update Quickstart documentation
   Files: `README.md`
   Acceptance: Quickstart includes `make bootstrap && make up`.

6. Title: Verify gitignore handling
   Files: `.gitignore`
   Acceptance: `.env` is ignored and `.env.example` remains tracked.

7. Title: Add verification checklist
   Files: `openspec/changes/bootstrap-env-random-secrets/proposal.md`
   Acceptance: Checklist covers `.env` creation, secret length, and non-overwrite behavior.
