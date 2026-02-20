# Change: Smoke Tests Dependencies and Gitignore Fix

## Summary
Remove unnecessary `rg` dependency from smoke tests (or validate it explicitly) and ensure Traefik dynamic templates are versionable.

## Problem
- Smoke tests rely on `rg`, but `scripts/healthcheck.sh` does not validate its presence, leading to failures on systems without ripgrep.
- `.gitignore` ignores `services/traefik/dynamic/`, which can prevent templates from being committed.

## Goals
- Reduce smoke test dependencies to common POSIX tools (`grep`/`awk`) or ensure healthcheck validates `rg` when required.
- Make `services/traefik/dynamic/` trackable in git by removing the blanket ignore.
- Keep changes minimal and scoped to tests, healthcheck, and `.gitignore`.

## Non-goals
- No functional changes to test logic beyond the `rg` replacement.
- No changes outside the allowed files list.

## Approach
- Replace `rg` usage in smoke tests with equivalent `grep -E`/`grep -q`/`awk`.
- Adjust `scripts/healthcheck.sh` based on whether `rg` remains required.
- Update `.gitignore` to stop ignoring `services/traefik/dynamic/`, while still ignoring generated artifacts (e.g., `dynamic-rendered/`).

## Affected files
- `tests/smoke/test_traefik_ready.sh`
- `tests/smoke/test_dns_service_config.sh`
- `scripts/healthcheck.sh`
- `.gitignore`

## Verification
- Smoke tests run without `rg` installed, or healthcheck clearly fails with an explicit `rg` dependency message.
- `services/traefik/dynamic/` files can be committed without `git add -f`.
