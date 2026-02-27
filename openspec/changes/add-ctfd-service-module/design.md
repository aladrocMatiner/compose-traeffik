## Context
The repo uses a consistent pattern for optional services: profile-gated Docker Compose services under `services/<module>/`, Traefik labels for HTTPS routing, Makefile wrapper targets, preflight env validation, smoke tests, and multilingual docs. CTFd introduces an app with internal stateful dependencies (database + cache), so the design must preserve this pattern without opening unnecessary ports.

## Goals
- Add CTFd as a first-class optional module integrated with Traefik.
- Keep DB/Redis private to an internal Docker network.
- Persist required secrets and credentials in `.env` via a dedicated bootstrap flow.
- Provide predictable Makefile workflows and no-sudo smoke tests.
- Keep implementation scope small enough for a medium-capability coding agent.

## Non-Goals
- Admin account auto-seeding
- Production hardening beyond baseline container/network/TLS safety
- SMTP, S3, plugin installation, or custom themes

## Proposed Topology
- `services/ctfd/compose.yml` defines three compose services under profile `ctfd`:
  - `ctfd`
  - `ctfd-db` (MariaDB)
  - `ctfd-redis` (Redis)
- Networks:
  - `proxy` for `ctfd` (Traefik routing)
  - a new internal network (e.g. `ctfd-internal`) for app<->db/cache traffic
- Ports:
  - no host-published ports for `ctfd`, `ctfd-db`, or `ctfd-redis`
  - Traefik remains the only public entry point
- Persistence (phase 1): named volumes for DB, Redis, uploads, and logs (exact names pinned in compose file)
- Startup coordination:
  - the module SHOULD define healthchecks (at least for MariaDB and Redis)
  - `ctfd` startup SHOULD be coordinated to reduce first-boot race conditions against DB/cache readiness

## Routing and TLS
- Hostname default: `ctfd.<DEV_DOMAIN>` (subdomain part configurable via `CTFD_HOSTNAME=ctfd`)
- Traefik routers follow the existing `*-web` / `*-websecure` pattern used by `whoami`
- Web router uses `${HTTP_TO_HTTPS_MIDDLEWARE:-redirect-to-https@file}`
- Websecure router uses `security-headers@file` and `${TLS_CERT_RESOLVER:-}` for Mode A/B/C compatibility
- CTFd app MUST receive `REVERSE_PROXY=true` to trust proxy headers / URL generation correctly

## Environment and Bootstrap
Planned `.env.example` additions (names are proposals; exact upstream compatibility verified before implementation):
- `CTFD_HOSTNAME=ctfd`
- `CTFD_IMAGE=<pinned-tag>`
- `CTFD_DB_IMAGE=<pinned-tag>`
- `CTFD_REDIS_IMAGE=<pinned-tag>`
- `CTFD_SECRET_KEY=`
- `CTFD_DB_NAME=ctfd`
- `CTFD_DB_USER=ctfd`
- `CTFD_DB_PASSWORD=`
- `CTFD_DB_ROOT_PASSWORD=`
- `CTFD_WORKERS=1`
- optional knobs (`CTFD_UPLOAD_FOLDER`, `CTFD_LOG_FOLDER`) may be fixed in compose if not needed as env

Bootstrap flow:
- `scripts/ctfd-bootstrap.sh`
- `make ctfd-bootstrap`
- behavior:
  - generate missing secrets (`CTFD_SECRET_KEY`, DB passwords)
  - persist into `.env`
  - do not overwrite existing values unless an explicit `--force`/rotation flag is provided
- first-run admin creation remains manual in the CTFd web UI and is documented in service README

## Guardrails
`validate-env.sh` additions SHOULD be profile-gated to `ctfd`:
- require non-empty `CTFD_SECRET_KEY`
- require non-empty DB credentials (`CTFD_DB_PASSWORD`, `CTFD_DB_ROOT_PASSWORD`)
- validate `CTFD_HOSTNAME` format (safe subdomain label)
- reject obvious placeholders for required secrets
- ensure checks do not fail when `ctfd` profile is disabled

## Testing Strategy (Phase 1)
No runtime integration test against a live CTFd app is required in this change. Add no-sudo smoke/static tests for:
- compose service wiring (`ctfd`, `ctfd-db`, `ctfd-redis`, profile, labels, no host ports)
- startup coordination wiring (healthcheck presence and/or readiness-oriented `depends_on` semantics if used)
- Makefile target wiring (`ctfd-*` and `make help` entries)
- guardrail behavior (profile-gated failures/success)
- bootstrap idempotency (`ctfd-bootstrap` fills `.env`, preserves existing values)

## Documentation Scope
- Root `README.md`, `README.es.md`, `README.sv.md`:
  - endpoint list entry for `https://ctfd.<DEV_DOMAIN>`
  - profile usage examples (`ctfd`)
  - note to add `ctfd` to `ENDPOINTS` (or clear `ENDPOINTS` to use auto-discovery) when using `hosts-*` helpers
  - link to service docs/tests/scripts docs
- `services/ctfd/README*.md`:
  - architecture (app + db + redis)
  - required env vars and `make ctfd-bootstrap`
  - first-run admin setup steps
  - backup/volume notes
  - troubleshooting
- `scripts/README.md`: include `ctfd-bootstrap.sh`
- `tests/README.md`: include new smoke tests
- `docs.manifest.json`: add `ctfd` service entry

## Upstream Verification Checklist (must do first in implementation)
1. Pin exact image tags for CTFd, MariaDB, and Redis (avoid `latest`).
2. Confirm env contract against CTFd docs/source for the chosen tag (`SECRET_KEY`, `DATABASE_URL`, `REDIS_URL`, `REVERSE_PROXY`).
3. Confirm whether CTFd image exposes port `8000` for the chosen tag.
4. Verify recommended DB/Redis versions from upstream docs and adjust tags accordingly.
5. Confirm startup ordering / healthcheck requirements for MariaDB + Redis.

## Implementation Order (recommended)
1. Add `services/ctfd/compose.yml` + service README stubs
2. Extend compose wrapper + Makefile targets
3. Add `.env.example` vars + `ctfd-bootstrap` script
4. Add guardrails
5. Add tests
6. Update docs and `docs.manifest.json`
7. Run `openspec validate`, smoke tests, and `make docs-check`
