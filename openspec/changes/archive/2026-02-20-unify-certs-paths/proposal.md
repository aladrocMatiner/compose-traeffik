# Change: Unify Certificate Paths

## Summary
Standardize all certificate paths on `shared/certs/` to avoid mismatches between docs, runtime, and tests.

## Problem
The repo mixes `certs/` and `shared/certs/` across docs, runtime mounts, and tests. This can cause users to trust or verify the wrong CA path.

## Goals
- Establish `shared/certs/` as the single canonical certs location.
- Introduce a single variable (`CERTS_DIR=shared/certs`) and use it consistently.
- Align scripts, compose mounts, tests, and docs to the same path.

## Non-goals
- No refactors beyond path alignment.
- No new paths beyond `shared/certs/`.

## Approach
- Add `CERTS_DIR=shared/certs` to the Makefile (and propagate to scripts/tests as needed).
- Replace all `certs/` references with `shared/certs/` in allowed files.
- Ensure generation, mounts, and validation (CA trust) use the same canonical path.

## Affected files
- `Makefile`
- `scripts/certs-selfsigned-generate.sh`
- `services/traefik/compose.yml`
- `tests/smoke/test_tls_handshake.sh`
- `docs/05-tls/mode-a-selfsigned.md`

## Verification
- `make certs-local` writes under `shared/certs/`.
- Traefik mounts and smoke tests reference `shared/certs/` consistently.
- Docs mention only `shared/certs/`.
