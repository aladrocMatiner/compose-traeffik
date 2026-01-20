# Change: Add production vs full bootstrap modes

## Summary
Introduce two bootstrap modes: a production-focused path that enables only minimal endpoints, and a full path that preserves the current all-options behavior. Default `make bootstrap` should use production mode; a new `make bootstrap-full` should use the full mode. Update the quickstart to reflect the default production path and the full alternative.

## Problem
Today the bootstrap flow generates a full `.env` with optional profiles enabled by default. This is convenient for local demos but is not aligned with a minimal production-style startup path. Users need a clear, safe default that only enables required endpoints, plus an explicit full option.

## Goals
- Provide two bootstrap modes: production-minimal and full.
- Make `make bootstrap` use production-minimal defaults.
- Add `make bootstrap-full` for the full current behavior.
- Update quickstart documentation (all languages) to reflect both options.

## Non-goals
- Changing runtime services beyond env defaults.
- Introducing new services or removing existing profiles.
- Refactoring unrelated scripts.

## Approach
- Split env generation into two modes (separate scripts or a single script with a `--mode` flag).
- Define production-minimal defaults (only required endpoints/profiles) and keep full defaults as they are today.
- Adjust Makefile targets so `bootstrap` uses production mode and `bootstrap-full` uses full mode.
- Update quickstart sections in `README.md`, `README.es.md`, and `README.sv.md` to mention both paths.

## Affected files
- `scripts/env-generate.sh` (or new `scripts/env-generate-prod.sh`/`scripts/env-generate-full.sh`)
- `Makefile`
- `README.md`
- `README.es.md`
- `README.sv.md`

## Verification
- `make bootstrap` produces `.env` with production-minimal defaults.
- `make bootstrap-full` produces `.env` with full defaults (current behavior).
- Quickstart docs in all languages mention both options.
