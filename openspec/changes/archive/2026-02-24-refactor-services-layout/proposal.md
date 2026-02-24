# Change: Refactor repository into services/ layout with compose layering

## Why
The repo is growing and service assets are spread across top-level folders. Consolidating each service under `services/<service>/` will improve clarity, ownership, and maintainability without changing workflows.

## Discovery Summary
- **Services in docker-compose.yml**: traefik, whoami, dns, certbot, step-ca.
- **Profiles**: dns, le (certbot), stepca (step-ca).
- **Current config/data directories**:
  - `traefik/` (static + dynamic config)
  - `step-ca/` (config, secrets)
  - `dns/` (data)
  - `shared/certs/` (local CA and leaf certs)
  - `certbot/` referenced in compose (conf/, www/) but directory not currently present.
- **Scripts/tests layout**: `scripts/` at root for lifecycle, certs, step-ca, DNS, and hosts; `tests/smoke/` for smoke tests.
- **Paths in compose**: mounts from `./traefik`, `./dns`, `./step-ca`, `./certbot`, `./certs` plus a named volume for Traefik ACME and step-ca data.

## What Changes
- Move service definitions into `services/<service>/compose.yml` and service assets under `services/<service>/(config|dynamic|data|secrets)/` as applicable.
- Add per-service `services/<service>/README.md` with run/config/test notes.
- Introduce a simple compose layering strategy: Makefile invokes `docker compose -f compose/base.yml -f services/<service>/compose.yml ...` (single, documented strategy).
- Keep root workflows intact: `make up`, `make down`, `make logs`, `make test`, TLS targets, and profiles retain current behavior.
- Add migration notes: what moved where and how to update custom overrides.

## Impact
- Affected specs: services-layout
- Affected code/docs: docker-compose.yml (replaced by compose layering), Makefile, scripts, service configs and data paths, docs and per-service READMEs.
