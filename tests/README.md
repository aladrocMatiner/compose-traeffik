# Smoke Tests for Traefik Edge Stack

This directory contains smoke tests that verify Traefik readiness, routing, TLS, and auxiliary tooling (hosts/DNS scripts). The tests are designed to be fast and provide immediate feedback on the stack state.

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
| `tests/smoke/test_routing.sh` | Confirm `https://whoami.${DEV_DOMAIN}` routes to whoami. | Stack running, `curl`, `DEV_DOMAIN`, hosts/DNS mapping. | Response contains `Hostname`. |
| `tests/smoke/test_tls_handshake.sh` | Validate TLS handshake and cert CN for `whoami.${DEV_DOMAIN}`. | Stack running, `openssl`, `DEV_DOMAIN`, `shared/certs/local-ca/ca.crt`. | Handshake succeeds and cert verifies against local CA. |
| `tests/smoke/test_http_redirect.sh` | Check HTTP to HTTPS redirect behavior. | Stack running, `curl`, `DEV_DOMAIN`, redirect config in `.env`. | Redirects to HTTPS when enabled, otherwise returns HTTP 200. |
| `tests/smoke/test_hosts_subdomains.sh` | Validate hosts block apply/remove using a temp file. | None (uses temp env/hosts). | Managed block is added then removed. |
| `tests/smoke/test_dns_provision.sh` | Check DNS provision dry-run output. | None (uses temp env). | Output includes expected loopback mappings. |
| `tests/smoke/test_dns_configure_ubuntu.sh` | Check dns-configure-ubuntu dry-run output. | None (uses temp env). | Output includes `resolvectl` commands for DNS and domain. |
| `tests/smoke/test_dns_service_config.sh` | Validate DNS compose fragment and middleware wiring. | Compose/middleware files present. | Service config contains expected profile, bindings, and auth wiring. |

## Configuration

Smoke tests use environment variables loaded from `.env` via `scripts/healthcheck.sh`:
- `DEV_DOMAIN`
- `HTTP_TO_HTTPS_REDIRECT`
- `HTTP_TO_HTTPS_MIDDLEWARE` (preferred when set)

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
  - Fix: set `HTTP_TO_HTTPS_MIDDLEWARE=redirect-to-https@file` and restart (`make up`).

- **DNS tests fail**
  - Symptom: DNS dry-run tests fail.
  - Diagnose: verify `BASE_DOMAIN`, `LOOPBACK_X`, `ENDPOINTS` in `.env`.
  - Fix: update `.env` and re-run `make test`.
