# Change: Add env generator option to quickstart

## Summary
Update the quickstart to include a script-based .env creation path that fills all available options, so new users can bootstrap quickly without manual edits.

## Problem
The quickstart only references `make bootstrap`, which can obscure the standalone script option and the ability to regenerate a complete `.env` from `.env.example` with populated defaults. This reduces discoverability for users who want a one-shot env creation path.

## Goals
- Document a quickstart path that explicitly uses the env generation script to create `.env` with all available options.
- Keep quickstart instructions consistent across all README languages.

## Non-goals
- Changing runtime behavior or defaults.
- Adding new scripts or refactoring bootstrap logic.

## Approach
- Update the Quickstart section in `README.md`, `README.es.md`, and `README.sv.md` to include a short, explicit option using `./scripts/env-generate.sh` (and the optional `--force` flag for regenerating).
- Keep the existing `make bootstrap` path and position the script option as an alternative for users who want a full .env generated from `.env.example`.

## Affected files
- `README.md`
- `README.es.md`
- `README.sv.md`

## Verification
- Quickstart in all three READMEs includes the env generator script option.
- The wording stays aligned across languages and preserves existing steps.
