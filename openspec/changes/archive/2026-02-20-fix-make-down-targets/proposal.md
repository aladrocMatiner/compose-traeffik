# Change: Fix Makefile *-down Targets

## Summary
Make `*-down` targets idempotent and valid by replacing `docker compose down <service>` with service-scoped stop/remove commands.

## Problem
`docker compose down` does not accept a service name. Targets like `stepca-down` and `dns-down` either fail or behave unpredictably.

## Goals
- Replace invalid `down <service>` usage with `stop <service>` + `rm -f <service>`.
- Keep behavior service-scoped (do not tear down the full stack).
- Avoid removing volumes by default.
- Ensure targets are idempotent (safe to run twice).

## Non-goals
- No refactor or changes outside the Makefile.
- No new purge/cleanup targets that remove volumes.

## Approach
- Identify all `*-down` targets that pass a service name to `docker compose down`.
- Replace them with `docker compose stop <service> || true` and `docker compose rm -f <service> || true`.
- Update any help text in the Makefile to reflect the new behavior.

## Affected files
- `Makefile`

## Verification
- Run `make stepca-down` twice; both runs succeed without error and only affect `step-ca`.
- Run `make dns-down` twice; both runs succeed without error and only affect `dns`.
- Running `make up` afterwards still works as expected.
