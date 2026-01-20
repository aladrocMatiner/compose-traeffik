# Change: Ensure DNS endpoint appears in hosts-subdomains output

## Summary
Make sure the DNS endpoint is included when generating hosts entries, even when `ENDPOINTS` is set, and document the `--mode` options for env generation.

## Problem
Users running the quickstart with full defaults still miss the DNS host entry because `ENDPOINTS` overrides auto-detection and may omit `dns`. This causes `make hosts-generate` to exclude the DNS entry.

## Goals
- Ensure the DNS endpoint appears in the hosts-subdomains output for full/default usage.
- Keep `--mode` usage visible in documentation to clarify production vs full bootstraps.

## Non-goals
- Changing routing behavior or service compose definitions.
- Introducing new endpoints beyond existing services.

## Approach
- Adjust default endpoints used by the env generation path so that full mode includes `dns` explicitly.
- If `ENDPOINTS` is set, ensure it is normalized or validated to include known endpoints for the active mode.
- Update quickstart docs (all languages) to mention the `--mode` option where env generation is discussed.

## Affected files
- `scripts/env-generate.sh`
- `.env.example`
- `scripts/hosts-subdomains.sh`
- `README.md`
- `README.es.md`
- `README.sv.md`

## Verification
- `make bootstrap-full` followed by `make hosts-generate` includes `dns.${BASE_DOMAIN}`.
- Quickstart docs mention `--mode` for env generation in all languages.
