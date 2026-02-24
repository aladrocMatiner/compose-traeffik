# Smoke Tests for Traefik Edge Stack

This directory contains smoke tests that verify Traefik readiness, routing, TLS, and auxiliary tooling (hosts scripts). The tests are designed to be fast and provide immediate feedback on the stack state.

## How to run

1. **Ensure the stack is running**
   ```bash
   make up
   ```
   If you are starting from scratch, run `make bootstrap` first to generate `.env`.

2. **Run all smoke tests**
   ```bash
   make test
   ```
   This runs `scripts/healthcheck.sh`, which executes all scripts in `tests/smoke/`.

3. **Run a single test**
   ```bash
   ./tests/smoke/test_routing.sh
   ```
   Note: `make test` is recommended because it loads `.env` and checks prerequisites.

## Test inventory

| Script | Purpose | Prerequisites | Expected signal |
| --- | --- | --- | --- |
| `tests/smoke/test_traefik_ready.sh` | Verify Traefik container runs and docker provider config is present. | Stack running, `docker`. | Logs success message about readiness and provider config. |
| `tests/smoke/test_routing.sh` | Confirm `https://whoami.${DEV_DOMAIN}` routes to whoami. | Stack running, `curl`, `DEV_DOMAIN`, hosts mapping. | Response contains `Hostname`. |
| `tests/smoke/test_tls_handshake.sh` | Validate TLS handshake and cert CN for `whoami.${DEV_DOMAIN}`. | Stack running, `openssl`, `DEV_DOMAIN`, `shared/certs/local-ca/ca.crt`. | Handshake succeeds and cert verifies against local CA. |
| `tests/smoke/test_http_redirect.sh` | Check HTTP to HTTPS redirect behavior. | Stack running, `curl`, `DEV_DOMAIN`, redirect config in `.env`. | Redirects to HTTPS when enabled, otherwise returns HTTP 200. |
| `tests/smoke/test_hosts_subdomains.sh` | Validate hosts block apply/remove using a temp file. | None (uses temp env/hosts). | Managed block is added then removed. |
| `tests/smoke/test_bind_service_config.sh` | Validate BIND compose fragment and bindings. | Compose file present. | Service config contains expected profile, bindings, and mounts. |
| `tests/smoke/test_bind_zone_generation.sh` | Validate BIND zone generation logic from `ENDPOINTS` in dry-run mode. | `scripts/bind-provision.sh`, `mktemp`, `awk`, `grep`. | Zone output contains expected records and ordering, deduplicates endpoints, and ignores `bind` endpoint duplicates. |
| `tests/smoke/test_bind_make_targets.sh` | Validate BIND Make lifecycle targets and compose profile wiring. | `Makefile`, `awk`, `grep`. | Required BIND targets exist and lifecycle commands use `scripts/compose.sh --profile bind`. |
| `tests/smoke/test_bind_guardrails.sh` | Validate preflight guardrails for BIND bind-address exposure. | `scripts/validate-env.sh`. | Non-local bind fails by default and only passes with explicit override. |
| `tests/smoke/test_bind_file_permissions.sh` | Validate config/zone file permissions are not world-writable. | `stat`, generated zone file or `bind-provision`. | Template, zone dir, and zone file reject world-writable modes. |
| `tests/smoke/test_bind_provisioning_validation.sh` | Validate `bind-provision` rejects invalid domain and endpoint labels. | `mktemp`, `scripts/bind-provision.sh`. | Invalid `BASE_DOMAIN` or endpoint labels fail with non-zero exit. |
| `tests/smoke/test_bind_security_runtime.sh` | Validate runtime DNS security behavior (no recursion, AXFR denied, hidden CHAOS metadata, expected listener). | `dig`, `docker`, `make`, loopback test address. | Security checks pass and BIND responds only on the expected test bind address. |
| `tests/smoke/test_ctfd_service_config.sh` | Validate CTFd compose wiring (app+db+redis), Traefik labels, no host ports, and startup coordination. | `services/ctfd/compose.yml`, `grep`, `awk`. | Compose fragment contains expected profile, internal network, labels, volumes, and healthchecks. |
| `tests/smoke/test_ctfd_guardrails.sh` | Validate preflight guardrails for CTFd secrets and hostname label. | `scripts/validate-env.sh`. | Missing/invalid CTFd config fails; valid config passes. |
| `tests/smoke/test_ctfd_make_targets.sh` | Validate CTFd Make target wiring and compose wrapper usage. | `Makefile`, `awk`, `grep`. | `ctfd-*` targets exist and lifecycle targets use `scripts/compose.sh --profile ctfd`. |
| `tests/smoke/test_ctfd_bootstrap_env.sh` | Validate `ctfd-bootstrap` secret generation and idempotency. | `.env.example`, `scripts/ctfd-bootstrap.sh`, `mktemp`. | Missing CTFd secrets are generated and preserved on rerun. |
| `tests/smoke/test_observability_service_config.sh` | Validate observability compose wiring, exposure rules, and Prometheus internal reachability to Traefik. | `services/observability/compose.yml`, `grep`, `awk`. | Grafana is routed, Prometheus/Loki are internal-only, Prometheus joins `proxy`, Alloy mounts are read-only. |
| `tests/smoke/test_observability_traefik_config.sh` | Validate Traefik metrics + JSON access logs configuration and sensitive-header redaction settings. | `services/traefik/traefik.yml`, `grep`. | Metrics and access log settings exist with header drops for auth/cookies. |
| `tests/smoke/test_observability_guardrails.sh` | Validate observability preflight guardrails and warn-only behavior without CTFd. | `scripts/validate-env.sh`. | Missing Grafana password fails; observability-only mode passes with warning. |
| `tests/smoke/test_observability_make_targets.sh` | Validate observability Make target wiring and compose wrapper usage. | `Makefile`, `awk`, `grep`. | `observability-*` targets exist and lifecycle targets use `scripts/compose.sh --profile observability`. |
| `tests/smoke/test_observability_bootstrap_env.sh` | Validate `observability-bootstrap` secret generation and idempotency. | `.env.example`, `scripts/observability-bootstrap.sh`, `mktemp`. | Missing Grafana secrets are generated and preserved on rerun. |
| `tests/smoke/test_observability_grafana_provisioning.sh` | Validate Grafana datasources and dashboard provisioning assets for core + CTFd pack. | Grafana provisioning files and dashboard JSON. | Prometheus/Loki datasources and dashboard paths/queries are present. |
| `tests/smoke/test_observability_app_pack_tolerance.sh` | Validate app-specific observability assets do not create a hard dependency on CTFd being enabled. | Alloy config, `scripts/validate-env.sh`. | Discovery-based CTFd log targeting is present and observability-only preflight still passes. |

## Configuration

Smoke tests use environment variables loaded from `.env` via `scripts/healthcheck.sh`:
- `DEV_DOMAIN`
- `HTTP_TO_HTTPS_REDIRECT`
- `HTTP_TO_HTTPS_MIDDLEWARE` (preferred when set)
- `BIND_BIND_ADDRESS` (default listener for BIND)
- `BIND_ALLOW_NONLOCAL_BIND` (must be `true` to allow non-loopback bind)
- `BIND_SECURITY_TEST_ADDRESS` (optional loopback override for runtime security smoke)
- `CTFD_*` (used by CTFd guardrail/bootstrap tests when provided inline)
- `GRAFANA_*` (used by observability guardrail/bootstrap tests when provided inline)

Ensure `.env` exists (prefer `make bootstrap`) before running tests. Optional profiles
are enabled by default via `COMPOSE_PROFILES` in `.env`; edit it if you want a smaller stack.

## Expected output

- `make test` prints per-test results and exits with non-zero status on failure.
- A successful run ends with `All smoke tests passed!`.

## Common failures and fixes

- **Traefik not ready / provider disabled**
  - Symptom: `test_traefik_ready.sh` fails.
  - Diagnose: `make ps`, `make logs traefik`, verify docker provider config in `services/traefik/traefik.yml`.
  - Fix: `make up`, ensure ports 80/443 are free and docker provider is enabled.

- **Routing fails**
  - Symptom: `test_routing.sh` fails to reach `whoami.${DEV_DOMAIN}`.
  - Diagnose: check `/etc/hosts` or DNS, `make logs traefik`.
  - Fix: `sudo make hosts-apply` or update DNS.

- **TLS handshake fails**
  - Symptom: `test_tls_handshake.sh` fails.
  - Diagnose: `make logs traefik`, confirm cert files exist.
  - Fix: `make certs-local`, then `make up`.

- **HTTP redirect fails**
  - Symptom: `test_http_redirect.sh` fails.
  - Diagnose: check `HTTP_TO_HTTPS_MIDDLEWARE` (or `HTTP_TO_HTTPS_REDIRECT` if unset) in `.env`.
  - Fix: for redirect enabled set `HTTP_TO_HTTPS_MIDDLEWARE=redirect-to-https@file`; for disabled behavior set `HTTP_TO_HTTPS_MIDDLEWARE=noop@file`; then restart (`make up`).

- **BIND zone generation fails**
  - Symptom: `test_bind_zone_generation.sh` fails.
  - Diagnose: run `./scripts/bind-provision.sh --dry-run` and inspect `BASE_DOMAIN`, `LOOPBACK_X`, `ENDPOINTS`.
  - Fix: correct `.env` values and re-run tests.

- **BIND Make targets wiring fails**
  - Symptom: `test_bind_make_targets.sh` fails.
  - Diagnose: run `make help` and inspect BIND target definitions in `Makefile`.
  - Fix: ensure lifecycle targets are present and wired through `./scripts/compose.sh --profile bind`.

- **BIND guardrails fail**
  - Symptom: `test_bind_guardrails.sh` fails.
  - Diagnose: inspect `BIND_BIND_ADDRESS` and `BIND_ALLOW_NONLOCAL_BIND` values.
  - Fix: use loopback bind by default; only set `BIND_ALLOW_NONLOCAL_BIND=true` when intentionally exposing DNS.

- **BIND runtime security fails**
  - Symptom: `test_bind_security_runtime.sh` fails.
  - Diagnose: check `make bind-logs` and inspect recursion/AXFR/CHAOS behavior with `dig`.
  - Fix: verify `named.conf.template` hardening directives and BIND compose command validation steps.

- **BIND provisioning validation fails**
  - Symptom: `test_bind_provisioning_validation.sh` fails.
  - Diagnose: inspect `BASE_DOMAIN` format and endpoint labels in `ENDPOINTS`.
  - Fix: use lowercase DNS labels only (`a-z`, `0-9`, internal `-`) and valid dot-separated domain format.
