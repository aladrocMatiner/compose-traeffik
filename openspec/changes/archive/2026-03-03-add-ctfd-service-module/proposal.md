# Change: Add CTFd service module (Traefik-integrated)

## Why
The repository currently provides an edge stack (Traefik + TLS/DNS helpers) but no application service for security training or CTF events. Adding CTFd as a first-class module enables a realistic target application while keeping the same Compose/Make/docs/test workflows used by the rest of the project.

## Discovery Summary (for implementer)
- Compose is layered via `compose/base.yml` + `services/*/compose.yml`, orchestrated by `scripts/compose.sh` and the root `Makefile`.
- New modules are expected under `services/<service>/` with `compose.yml` and multilingual READMEs.
- Preflight validation runs before compose commands via `scripts/validate-env.sh`.
- Smoke tests are inventory-driven via `scripts/healthcheck.sh` and `tests/smoke/*`.
- CTFd upstream docker-compose uses `ctfd` + `mariadb` + `redis` and sets `REVERSE_PROXY=true`, `DATABASE_URL`, `REDIS_URL`, `UPLOAD_FOLDER`, and log paths.
- CTFd runtime config source (`CTFd/config.py`) confirms env-based keys such as `SECRET_KEY`, `DATABASE_URL`, `REDIS_URL`, `UPLOAD_FOLDER`, and `REVERSE_PROXY`.

## What Changes
- Add a new optional profile-backed service module `services/ctfd/compose.yml` that deploys:
  - `ctfd` application container
  - internal `mariadb` database container
  - internal `redis` cache container
- Expose CTFd only through Traefik at `https://ctfd.<DEV_DOMAIN>` (no direct host port for CTFd app).
- Add `.env.example` variables for CTFd hostname/image/runtime config and DB/cache credentials.
- Add `make ctfd-bootstrap` to generate/persist required CTFd secrets in `.env` (idempotent by default).
- Add `make ctfd-up/down/restart/logs/status` targets using the shared compose wrapper.
- Add preflight guardrails for CTFd profile activation (secrets/hostname/safety checks).
- Add smoke tests (static config/guardrails/make wiring) and docs updates (root + service + scripts/tests docs + `docs.manifest.json`).

## Non-Goals (Phase 1)
- Auto-provisioning the first CTFd admin user via API/script.
- CTFd plugin ecosystem management.
- External object storage, SMTP, or SSO integration.
- Horizontal scaling / worker separation beyond a single app container.

## Impact
- Affected specs:
  - `ctfd-service` (new)
  - `compose-wrapper`
  - `guardrails`
  - `bootstrap-secrets`
  - `docs-endpoints-tls`
- Affected code/docs (planned):
  - `services/ctfd/compose.yml`
  - `services/ctfd/README*.md`
  - `.env.example`
  - `scripts/ctfd-bootstrap.sh`
  - `scripts/validate-env.sh`
  - `scripts/compose.sh` / `Makefile`
  - `scripts/healthcheck.sh`, `tests/smoke/*`
  - `README*.md`, `scripts/README.md`, `tests/README.md`, `docs.manifest.json`

## Dependencies / Order
- This change is independent and SHOULD land before the observability change so the monitoring stack can target a stable `ctfd` service name.
