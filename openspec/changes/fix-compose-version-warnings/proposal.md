# Change: Remove Compose Version Warnings

## Summary
Eliminate Docker Compose warnings about the deprecated `version` key in compose files.

## Problem
Running the stack emits warnings that the `version` attribute is obsolete in Compose v2. This adds noise and can confuse users during setup.

## Goals
- Remove the obsolete `version` field from compose files.
- Keep behavior unchanged.

## Non-goals
- No functional changes to services, networks, or volumes.
- No refactors of compose file structure.

## Approach
- Remove the `version: '3.8'` line from all compose fragments (`compose/base.yml` and `services/*/compose.yml`).
- Verify no other compose content is altered.

## Affected files
- `compose/base.yml`
- `services/traefik/compose.yml`
- `services/whoami/compose.yml`
- `services/dns/compose.yml`
- `services/certbot/compose.yml`
- `services/step-ca/compose.yml`

## Verification
- `docker compose` no longer emits the “attribute version is obsolete” warning.
