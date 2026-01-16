# Change: Document operational scripts and link from README

## Why
Operational scripts are the primary way to run and troubleshoot the stack, but there is no consolidated documentation in `scripts/README.md` and the root README does not point to it. A dedicated scripts reference will improve operational clarity and reduce trial-and-error.

## Discovery Summary
- **Scripts found**:
  - `scripts/compose.sh`: wrapper around layered compose files; uses `.env` via `--env-file`.
  - `scripts/up.sh`: starts stack, renders Traefik dynamic config; uses docker compose.
  - `scripts/down.sh`: stops stack.
  - `scripts/logs.sh`: follows logs; supports `--profile` passthrough.
  - `scripts/traefik-render-dynamic.sh`: renders Traefik dynamic templates using `DEV_DOMAIN`.
  - `scripts/healthcheck.sh`: runs smoke tests; requires `DEV_DOMAIN`, `HTTP_TO_HTTPS_REDIRECT`.
  - `scripts/certs-selfsigned-generate.sh`: generates local CA + leaf certs; requires `DEV_DOMAIN`.
  - `scripts/certbot-issue.sh`: issues LE certs (profile `le`); requires `DEV_DOMAIN`, `ACME_EMAIL`, `LETSENCRYPT_STAGING`.
  - `scripts/certbot-renew.sh`: renews LE certs (profile `le`); requires `LETSENCRYPT_STAGING`.
  - `scripts/stepca-bootstrap.sh`: bootstraps step-ca (profile `stepca`); requires `DEV_DOMAIN`, `STEP_CA_NAME`, `STEP_CA_ADMIN_PROVISIONER_PASSWORD`, `STEP_CA_PASSWORD`.
  - `scripts/stepca-trust-install.sh`: install step-ca root to Ubuntu trust store (sudo).
  - `scripts/stepca-trust-uninstall.sh`: remove step-ca root (sudo).
  - `scripts/stepca-trust-verify.sh`: verify step-ca root trust.
  - `scripts/hosts-subdomains.sh`: manage hosts block; requires `BASE_DOMAIN`, `LOOPBACK_X`; optional `ENDPOINTS`, `HOSTS_FILE`, `ENV_FILE`.
  - `scripts/dns-provision.sh`: provision DNS records; requires `BASE_DOMAIN`, `LOOPBACK_X`; requires `DNS_ADMIN_PASSWORD` unless `--dry-run`; optional `ENDPOINTS`.
  - `scripts/dns-configure-ubuntu.sh`: configure split-DNS on Ubuntu; requires `BASE_DOMAIN`.
  - `scripts/common.sh`: shared helpers (logging, env loading, checks).
- **Make targets calling scripts**:
  - `make up/down/logs/test`
  - `make certs-local`, `make certbot-issue`, `make certbot-renew`
  - `make stepca-bootstrap`, `make stepca-trust-install|uninstall|verify`
  - `make hosts-generate|apply|remove|status`
  - `make dns-provision`, `make dns-provision-dry`, `make dns-config-apply|remove|status`
- **Env vars used by scripts (present in `.env.example`)**:
  - `DEV_DOMAIN`, `BASE_DOMAIN`, `LOOPBACK_X`, `ENDPOINTS`, `HOSTS_FILE`, `ENV_FILE`
  - `HTTP_TO_HTTPS_REDIRECT`
  - `ACME_EMAIL`, `LETSENCRYPT_STAGING`
  - `STEP_CA_NAME`, `STEP_CA_ADMIN_PROVISIONER_PASSWORD`, `STEP_CA_PASSWORD`
  - `DNS_ADMIN_PASSWORD`, `DNS_BIND_ADDRESS`, `DNS_UI_HOSTNAME`, `DNS_UI_MIDDLEWARES`, `DNS_UI_ALLOWLIST_SOURCE_RANGES`
- **Compose profiles referenced by scripts**: `le`, `stepca`, `dns` (from `services/*/compose.yml` and script usage).
- **README.md**: Quickstart exists; a placeholder bullet for “Makefile & Scripts Operations (planned)” but no scripts link.

## What Changes
- Create or update `scripts/README.md` with a full inventory, usage guidance, env var requirements, workflows, safety notes, and troubleshooting.
- Add a visible link to `scripts/README.md` in the root README (Quickstart or an Operations section).

## Impact
- Affected specs: scripts-docs
- Affected files: `scripts/README.md`, `README.md` (link only)
