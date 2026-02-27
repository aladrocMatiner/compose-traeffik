## 1. Upstream Verification (before coding)
- [x] 1.1 Verify CTFd image tag to pin and supported env vars for the selected version.
- [x] 1.2 Verify recommended MariaDB and Redis image tags/versions for CTFd compatibility.
- [x] 1.3 Verify CTFd reverse-proxy guidance (`REVERSE_PROXY`, headers) and default app port.

## 2. Service Module: `services/ctfd/`
- [x] 2.1 Create `services/ctfd/compose.yml` with profile `ctfd` and services `ctfd`, `ctfd-db`, `ctfd-redis`.
- [x] 2.2 Add internal network wiring so DB/Redis are not exposed on the `proxy` network unless required.
- [x] 2.3 Add Traefik labels for HTTP/HTTPS routers on `ctfd` using repo middleware/TLS conventions.
- [x] 2.4 Add named volumes for CTFd uploads/logs and database/cache persistence.
- [x] 2.5 Configure CTFd env vars (`DATABASE_URL`, `REDIS_URL`, `REVERSE_PROXY=true`, etc.) from `.env`.
- [x] 2.6 Ensure no direct host port is published for the CTFd app, DB, or Redis.
- [x] 2.7 Add healthchecks and/or startup coordination to reduce DB/Redis readiness race conditions for CTFd.

## 3. Environment Template and Bootstrap
- [x] 3.1 Add `CTFD_*` variables to `.env.example` (hostname, images, secrets, DB/cache config).
- [x] 3.2 Create `scripts/ctfd-bootstrap.sh` to generate/persist missing secrets in `.env`.
- [x] 3.3 Make `ctfd-bootstrap` idempotent by default and support explicit rotation/force.
- [x] 3.4 Add `make ctfd-bootstrap` target and help text.
- [x] 3.5 Add `make ctfd-up/down/restart/logs/status` targets using `scripts/compose.sh --profile ctfd`.

## 4. Guardrails
- [x] 4.1 Extend `scripts/validate-env.sh` with profile-gated CTFd checks for required secrets.
- [x] 4.2 Validate `CTFD_HOSTNAME` format and reject invalid/unsafe values.
- [x] 4.3 Ensure guardrails do not fail when `ctfd` profile is not enabled.

## 5. Tests (no-sudo smoke/static)
- [x] 5.1 Add `tests/smoke/test_ctfd_service_config.sh` to validate compose wiring, labels, and no host ports.
- [x] 5.2 Ensure the CTFd service config test also validates startup coordination wiring (healthchecks or readiness `depends_on` if implemented).
- [x] 5.3 Add `tests/smoke/test_ctfd_guardrails.sh` for profile-gated preflight validation behavior.
- [x] 5.4 Add `tests/smoke/test_ctfd_make_targets.sh` to validate Makefile wiring/help output.
- [x] 5.5 Add `tests/smoke/test_ctfd_bootstrap_env.sh` for `.env` secret generation + idempotency.
- [x] 5.6 Integrate new tests into `scripts/healthcheck.sh` in a stable order.

## 6. Documentation
- [x] 6.1 Update root `README.md` with CTFd endpoint/profile usage and links.
- [x] 6.2 Update root `README.es.md` with matching CTFd content.
- [x] 6.3 Update root `README.sv.md` with matching CTFd content.
- [x] 6.4 Document `hosts-*`/`ENDPOINTS` implications for adding the `ctfd` endpoint (or auto-discovery mode) in root docs.
- [x] 6.5 Create `services/ctfd/README.md` (overview, env, bootstrap, first-run admin setup, troubleshooting).
- [x] 6.6 Create `services/ctfd/README.es.md` with structural parity.
- [x] 6.7 Create `services/ctfd/README.sv.md` with structural parity.
- [x] 6.8 Update `scripts/README.md` with `ctfd-bootstrap.sh`.
- [x] 6.9 Update `tests/README.md` smoke test inventory/table entries.
- [x] 6.10 Update `docs.manifest.json` to include the new service docs.

## 7. Validation and Handoff
- [x] 7.1 Run `openspec validate add-ctfd-service-module --strict`.
- [x] 7.2 Run `make docs-check`.
- [x] 7.3 Run the new CTFd smoke tests individually.
- [x] 7.4 Run `make test` and record any unrelated pre-existing failures.

Note: `make test` still reports the pre-existing BIND runtime smoke failure in `tests/smoke/test_bind_security_runtime.sh` (`Expected recursion to be disabled, but query looked permissive.`).
