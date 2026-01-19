# Change: Bootstrap Env With Random Secrets

## Summary
Add a zero‑friction bootstrap flow that generates a local `.env` with safe defaults and strong random secrets, and provides a single command to prepare the repo for `make up`.

## Problem
New users must manually copy and edit `.env`, generate secrets, and create directories before the stack starts cleanly. This slows onboarding and leads to missing/weak defaults.

## Goals
- Provide a one‑command bootstrap (`make bootstrap`) that generates a `.env` if missing and fills empty secrets securely.
- Keep `.env` uncommitted while `.env.example` remains versioned.
- Make the generation idempotent (no overwrite unless explicitly forced).
- Use portable random generation (python3 preferred, openssl fallback).

## Non-goals
- No changes to runtime behavior beyond environment initialization.
- No secret storage or encryption beyond local `.env`.

## Approach
- Add `scripts/env-generate.sh` that:
  - Creates `.env` from `.env.example` if missing.
  - Fills empty secret fields with secure random strings (min length 32).
  - Preserves existing values unless `--force` is provided.
- Add `make bootstrap` target to run the script and create required directories (e.g., `shared/certs`).
- Update Quickstart docs to recommend `make bootstrap && make up`.
- Add a simple local verification: `.env` exists, no placeholder secrets remain, and `.env` is ignored by git.

## Affected files
- `.gitignore`
- `.env.example`
- `scripts/env-generate.sh`
- `Makefile`
- `README.md` (Quickstart)

## Verification
- Running `make bootstrap` creates `.env` and does not overwrite existing values by default.
- Generated secrets are non-empty, length ≥ 32, and `.env` stays untracked.
