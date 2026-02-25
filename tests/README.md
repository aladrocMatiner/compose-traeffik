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

   GitLab-only static smoke suite:
   ```bash
   make test-gitlab
   ```

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
| `tests/smoke/test_gitlab_make_targets.sh` | Validate GitLab Make lifecycle/test targets and compose wrapper wiring. | `Makefile`, `awk`, `grep`. | GitLab targets exist and lifecycle targets use `scripts/compose.sh --profile gitlab`. |
| `tests/smoke/test_gitlab_service_config.sh` | Validate GitLab compose fragment (Traefik routing, SSH port publish, no HTTP/HTTPS host ports, volumes). | `services/gitlab/compose.yml`, `grep`. | Expected labels/mounts exist and no direct public web ports are published. |
| `tests/smoke/test_gitlab_guardrails.sh` | Validate GitLab preflight checks (SSH port, rendered config requirement, OIDC required vars and HTTPS issuer). | `scripts/validate-env.sh`, `mktemp`. | Invalid settings fail; valid OIDC config passes. |
| `tests/smoke/test_gitlab_oidc_wiring.sh` | Validate GitLab Omnibus config rendering toggles OIDC block correctly. | `scripts/gitlab-render-config.sh`, `python3`, `mktemp`. | OIDC block is omitted when disabled and rendered with callback/issuer when enabled. |
| `tests/smoke/test_gitlab_observability_wiring.sh` | Validate observability labels/hooks and default telemetry non-exposure for GitLab. | `services/gitlab/compose.yml`, `scripts/gitlab-render-config.sh`, `mktemp`. | No public telemetry ports/routes by default; observability toggle affects rendered exporter settings. |

## Configuration

Smoke tests use environment variables loaded from `.env` via `scripts/healthcheck.sh`:
- `DEV_DOMAIN`
- `HTTP_TO_HTTPS_REDIRECT`
- `HTTP_TO_HTTPS_MIDDLEWARE` (preferred when set)
- `BIND_BIND_ADDRESS` (default listener for BIND)
- `BIND_ALLOW_NONLOCAL_BIND` (must be `true` to allow non-loopback bind)
- `BIND_SECURITY_TEST_ADDRESS` (optional loopback override for runtime security smoke)
- `GITLAB_*` variables for GitLab static smoke tests (`make test-gitlab` and GitLab checks inside `make test`)

Ensure `.env` exists (prefer `make bootstrap`) before running tests. Optional profiles
are enabled by default via `COMPOSE_PROFILES` in `.env`; edit it if you want a smaller stack.

## Expected output

- `make test` prints per-test results and exits with non-zero status on failure.
- A successful run ends with `All smoke tests passed!`.
- `make test-gitlab` runs static GitLab checks only (no full GitLab startup or OIDC token exchange).

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

- **GitLab guardrails fail**
  - Symptom: `test_gitlab_guardrails.sh` fails.
  - Diagnose: inspect `GITLAB_SSH_HOST_PORT`, `GITLAB_ROOT_PASSWORD`, and OIDC variables in `.env`.
  - Fix: run `make gitlab-bootstrap`, then update OIDC values if `GITLAB_OIDC_ENABLED=true`.

- **GitLab OIDC wiring test fails**
  - Symptom: `test_gitlab_oidc_wiring.sh` fails.
  - Diagnose: run `./scripts/gitlab-render-config.sh --output-file /tmp/gitlab.rb` and inspect the rendered file.
  - Fix: verify the template (`services/gitlab/config/gitlab.rb.tmpl`) and `GITLAB_OIDC_*` settings.
