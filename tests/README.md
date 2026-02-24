# Smoke Tests for Traefik Edge Stack

This directory contains smoke tests that verify Traefik readiness, routing, TLS, and auxiliary tooling (hosts/DNS/LiteLLM config scripts). The tests are designed to be fast and provide immediate feedback on the stack state.

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

- `tests/smoke/test_traefik_ready.sh`: verifies Traefik is running and docker provider config is enabled.
- `tests/smoke/test_routing.sh`: checks `https://whoami.${DEV_DOMAIN}` routes to whoami.
- `tests/smoke/test_tls_handshake.sh`: validates TLS handshake for `whoami.${DEV_DOMAIN}`.
- `tests/smoke/test_http_redirect.sh`: validates HTTP to HTTPS redirect when enabled.
- `tests/smoke/test_hosts_subdomains.sh`: validates hosts block apply/remove using a temp file (no sudo).
- `tests/smoke/test_dns_provision.sh`: checks DNS provisioning dry-run output.
- `tests/smoke/test_dns_configure_ubuntu.sh`: checks DNS configure dry-run output.
- `tests/smoke/test_dns_service_config.sh`: checks DNS service compose configuration.
- `tests/smoke/test_litellm_service_config.sh`: checks LiteLLM service compose configuration and Traefik exposure expectations.
- `tests/smoke/test_litellm_config_template.sh`: checks the committed LiteLLM config template structure and env placeholder usage.
- `tests/smoke/test_litellm_guardrails.sh`: checks LiteLLM preflight validation behavior (profile-gated, secrets, hostname).
- `tests/smoke/test_litellm_make_targets.sh`: checks Makefile target/help wiring for LiteLLM.
- `tests/smoke/test_litellm_bootstrap_env.sh`: checks LiteLLM bootstrap idempotency and `--force` rotation using a temp env file.
- `tests/smoke/test_litellm_standalone_mode_wiring.sh`: checks standalone `traefik + litellm` Make wiring and service-selection scope.

## Configuration

Smoke tests use environment variables loaded from `.env` via `scripts/healthcheck.sh`:
- `DEV_DOMAIN`
- `HTTP_TO_HTTPS_REDIRECT`
- `HTTP_TO_HTTPS_MIDDLEWARE` (preferred when set)

Ensure `.env` exists (prefer `make bootstrap`) before running tests. Optional profiles
are enabled by default via `COMPOSE_PROFILES` in `.env`; edit it if you want a smaller stack.
LiteLLM smoke tests do not require sudo and do not call external LLM providers.
LiteLLM local-inference tests validate config/bootstrap/guardrails only; they do not require the local backend to be reachable.
Standalone LiteLLM mode tests validate Make/config wiring and service selection, not remote `step-ca` certificate issuance at runtime.

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

- **LiteLLM config/guardrail tests fail**
  - Symptom: LiteLLM smoke tests fail on missing keys or invalid hostname.
  - Diagnose: check `LITELLM_HOSTNAME`, `LITELLM_UI_HOSTNAME`, `LITELLM_LOCAL_API_BASE`, `LITELLM_MASTER_KEY`, `LITELLM_SALT_KEY`, and `LITELLM_UI_BASIC_AUTH_HTPASSWD_PATH` in `.env`.
  - Fix: run `make litellm-bootstrap` (or `ENV_FILE=... make litellm-bootstrap`) and retry.
