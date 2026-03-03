## 1. Upstream Verification (before coding)
- [x] 1.1 Pin and verify image tags for Grafana, Prometheus, Loki, and Alloy.
- [x] 1.2 Verify Alloy config syntax and Docker log collection approach for the selected version.
- [x] 1.3 Verify Traefik v3 static config syntax for Prometheus metrics and JSON access logs.
- [x] 1.4 Verify Grafana env vars for admin credentials and secret key on the selected image tag.
- [x] 1.5 Verify Loki single-binary config schema used in the repo config file.

## 2. Traefik Instrumentation for Observability
- [x] 2.1 Update `services/traefik/traefik.yml` to enable Prometheus metrics (with router/service/entrypoint labels).
- [x] 2.2 Update `services/traefik/traefik.yml` to emit structured access logs suitable for Loki ingestion.
- [x] 2.3 Configure Traefik access logs to avoid logging sensitive headers by default (e.g. `Authorization`, cookies).
- [x] 2.4 Confirm metrics remain internal-only by default (no new host port and no public router for `prometheus@internal`).
- [x] 2.5 Document/verify the strong-default behavior: Traefik emits telemetry even when the `observability` profile is disabled, with no public exposure.

## 3. Observability Module: `services/observability/`
- [x] 3.1 Create `services/observability/compose.yml` with profile `observability` and services `grafana`, `prometheus`, `loki`, `alloy`.
- [x] 3.2 Add internal network wiring for observability backends and explicit network reachability for Prometheus to scrape Traefik (preferred: attach Prometheus to `proxy` while keeping it non-public).
- [x] 3.3 Add Traefik labels for Grafana HTTP/HTTPS routers using repo middleware/TLS conventions.
- [x] 3.4 Ensure Prometheus and Loki have no direct host ports and no Traefik labels by default.
- [x] 3.5 Add persistent volumes for Grafana, Prometheus (if persisted), and Loki.
- [x] 3.6 Document and implement Alloy mounts with read-only permissions where possible (Docker logs/socket trust boundary).

## 4. Observability Config Files
- [x] 4.1 Add Prometheus scrape config to collect Traefik metrics (and self-metrics if desired).
- [x] 4.2 Add Loki config for single-binary local deployment with bounded local persistence.
- [x] 4.3 Add Alloy config to collect Docker logs from `traefik` and the initial app target(s) (`ctfd*`) into Loki without failing when app containers are absent.
- [x] 4.4 Add Grafana provisioning for Prometheus and Loki datasources.
- [x] 4.5 Add starter dashboard(s) or documented Explore queries for Traefik metrics and Traefik/CTFd logs.
- [x] 4.6 Structure provisioning/config files so core observability assets and app-specific assets (CTFd) are clearly separable for future modules.
- [x] 4.7 Set bounded default retention/storage limits for Prometheus and Loki (with `.env` overrides where planned).

## 5. Environment Template and Bootstrap
- [x] 5.1 Add `GRAFANA_*`, `PROMETHEUS_*`, `LOKI_*`, and `ALLOY_*` image/hostname settings to `.env.example`.
- [x] 5.2 Add `scripts/observability-bootstrap.sh` to generate/persist Grafana admin secrets in `.env`.
- [x] 5.3 Make `observability-bootstrap` idempotent by default and support explicit rotation/force.
- [x] 5.4 Add `make observability-bootstrap` target and help text.
- [x] 5.5 Add `make observability-up/down/restart/logs/status` module targets using `scripts/compose.sh --profile observability`.

## 6. Guardrails
- [x] 6.1 Extend `scripts/validate-env.sh` with profile-gated observability checks.
- [x] 6.2 Validate `GRAFANA_HOSTNAME` format and non-placeholder `GRAFANA_ADMIN_PASSWORD`.
- [x] 6.3 Ensure observability checks do not block stacks where the `observability` profile is disabled.
- [x] 6.4 Prefer warn-only guidance (not hard fail) when `observability` is enabled without `ctfd` or other app-specific telemetry targets.

## 7. Tests (no-sudo smoke/static)
 - [x] 7.1 Add `tests/smoke/test_observability_service_config.sh` for compose wiring, networking, and exposure rules (including `prometheus` reachability to Traefik via Docker network without public exposure).
- [x] 7.2 Add `tests/smoke/test_observability_traefik_config.sh` for Traefik metrics/accesslog static config (including header redaction settings).
- [x] 7.3 Add `tests/smoke/test_observability_guardrails.sh` for profile-gated validation behavior.
- [x] 7.4 Add `tests/smoke/test_observability_make_targets.sh` for Makefile/help wiring.
- [x] 7.5 Add `tests/smoke/test_observability_bootstrap_env.sh` for `.env` secret generation + idempotency.
- [x] 7.6 Add `tests/smoke/test_observability_grafana_provisioning.sh` for datasource/dashboard file references.
- [x] 7.7 Add a smoke test to verify app-specific observability assets do not create a hard dependency on `ctfd` being enabled.
- [x] 7.8 Integrate new tests into `scripts/healthcheck.sh` in a stable order.

## 8. Documentation
- [x] 8.1 Update root `README.md` with observability profile usage, Grafana endpoint, and internal-only notes for Prometheus/Loki.
- [x] 8.2 Update root `README.es.md` with matching observability content.
- [x] 8.3 Update root `README.sv.md` with matching observability content.
- [x] 8.4 Create `services/observability/README.md` (architecture, bootstrap, verification, troubleshooting, and extension pattern for future services).
- [x] 8.5 Create `services/observability/README.es.md` with structural parity.
- [x] 8.6 Create `services/observability/README.sv.md` with structural parity.
- [x] 8.7 Update `scripts/README.md` with `observability-bootstrap.sh`.
- [x] 8.8 Update `tests/README.md` smoke test inventory/table entries.
- [x] 8.9 Update `docs.manifest.json` to include the new service docs.
- [x] 8.10 Document `hosts-*` / `ENDPOINTS` implications for adding the `grafana` endpoint (or using auto-discovery mode).

## 9. Validation and Handoff
- [x] 9.1 Run `openspec validate add-observability-stack-for-traefik-ctfd --strict`.
- [x] 9.2 Run `make docs-check`.
- [x] 9.3 Run the new observability smoke tests individually.
- [x] 9.4 Run `make test` and record any unrelated pre-existing failures.

Note: `make test` still reports the pre-existing BIND runtime smoke failure in `tests/smoke/test_bind_security_runtime.sh` (`Expected recursion to be disabled, but query looked permissive.`).
