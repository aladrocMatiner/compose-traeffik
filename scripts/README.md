# Operational scripts

This directory contains helper scripts used to operate the stack. Prefer running them via Make targets where available so environment loading and compose layering stay consistent.

## How to use

- Preferred: `make <target>` (see `make help` for a list).
- Direct: run the script from repo root, e.g. `./scripts/up.sh`.

Prerequisites:
- bash
- Docker + Docker Compose v2
- `.env` file (copy from `.env.example`)

Preflight validation:
- `scripts/validate-env.sh` runs before `make up` and any `scripts/compose.sh` call.
- It enforces safe defaults for admin UIs (DNS and dashboard) and validates profile syntax.
- Create htpasswd files under `services/traefik/auth/`, for example:
  - `htpasswd -nbB admin 'change-me' > services/traefik/auth/dns-ui.htpasswd`
  - `htpasswd -nbB admin 'change-me' > services/traefik/auth/traefik-dashboard.htpasswd`
- Set the container paths in `.env`:
  - `DNS_UI_BASIC_AUTH_HTPASSWD_PATH=/etc/traefik/auth/dns-ui.htpasswd`
  - `TRAEFIK_DASHBOARD_BASIC_AUTH_HTPASSWD_PATH=/etc/traefik/auth/traefik-dashboard.htpasswd`

## Script inventory

| Script | Purpose | Typical usage | Required env vars | Side effects |
| --- | --- | --- | --- | --- |
| `scripts/compose.sh` | Wrapper for layered compose files | `./scripts/compose.sh ps` | `.env` (via `--env-file`) | Runs docker compose |
| `scripts/up.sh` | Start the stack and render Traefik dynamic config | `make up` | none (loads `.env` if present) | Starts containers |
| `scripts/down.sh` | Stop the stack | `make down` | none | Stops containers |
| `scripts/logs.sh` | Follow service logs | `make logs` | none | Streams logs |
| `scripts/validate-env.sh` | Preflight validation for profiles and admin auth | `./scripts/validate-env.sh` | `COMPOSE_PROFILES`, `DNS_ADMIN_PASSWORD`, `DNS_UI_BASIC_AUTH_HTPASSWD_PATH`, `TRAEFIK_DASHBOARD_BASIC_AUTH_HTPASSWD_PATH`, `TRAEFIK_DASHBOARD` | Fails fast on unsafe config |
| `scripts/traefik-render-dynamic.sh` | Render Traefik dynamic config templates | `./scripts/traefik-render-dynamic.sh` | `DEV_DOMAIN` | Writes `services/traefik/dynamic-rendered` |
| `scripts/healthcheck.sh` | Run smoke tests | `make test` | `DEV_DOMAIN`, `HTTP_TO_HTTPS_REDIRECT` | Runs tests, exits non-zero on failure |
| `scripts/certs-selfsigned-generate.sh` | Generate local CA + leaf certs | `make certs-local` | `DEV_DOMAIN` | Writes `shared/certs/local-ca` and `shared/certs/local` |
| `scripts/certbot-issue.sh` | Issue LE certs (profile `le`) | `make certs-le-issue` | `DEV_DOMAIN`, `ACME_EMAIL`, `LETSENCRYPT_STAGING` | Runs certbot container, writes `services/certbot/conf` |
| `scripts/certbot-renew.sh` | Renew LE certs (profile `le`) | `make certs-le-renew` | `LETSENCRYPT_STAGING` | Runs certbot renew |
| `scripts/stepca-bootstrap.sh` | Bootstrap step-ca (profile `stepca`) | `make stepca-bootstrap` | `DEV_DOMAIN`, `STEP_CA_NAME`, `STEP_CA_ADMIN_PROVISIONER_PASSWORD`, `STEP_CA_PASSWORD` | Initializes step-ca data |
| `scripts/stepca-trust-install.sh` | Install step-ca root cert (Ubuntu 24.04) | `sudo make stepca-trust-install` | `STEPCA_CA_CERT_PATH` (optional) | Writes to system trust store |
| `scripts/stepca-trust-uninstall.sh` | Remove step-ca root cert (Ubuntu 24.04) | `sudo make stepca-trust-uninstall` | none | Removes system trust entry |
| `scripts/stepca-trust-verify.sh` | Verify step-ca root trust (Ubuntu 24.04) | `make stepca-trust-verify` | `STEPCA_CA_CERT_PATH` (optional) | Reads system trust store |
| `scripts/hosts-subdomains.sh` | Manage hosts block for loopback subdomains | `make hosts-apply` | `BASE_DOMAIN`, `LOOPBACK_X` | Modifies hosts file (with sudo) |
| `scripts/dns-provision.sh` | Provision DNS records (Technitium) | `make dns-provision` | `BASE_DOMAIN`, `LOOPBACK_X`, `DNS_ADMIN_PASSWORD` | Calls DNS API |
| `scripts/dns-configure-ubuntu.sh` | Configure split-DNS (Ubuntu 24.04) | `sudo make dns-config-apply` | `BASE_DOMAIN` | Updates systemd-resolved config |
| `scripts/common.sh` | Shared helpers | sourced by other scripts | none | none |

## Workflows

### Standard lifecycle

```bash
make up
make logs
make test
make down
```

### Certificates

Mode A (self-signed):
```bash
make certs-local
make up
```

Mode B (Lets Encrypt via Certbot, profile `le`):
```bash
COMPOSE_PROFILES=le make up
make certs-le-issue
```

Mode C (step-ca, profile `stepca`):
```bash
make stepca-up
make stepca-bootstrap
sudo make stepca-trust-install
COMPOSE_PROFILES=stepca make up
```

## Safety and idempotency

- Safe to rerun: `up.sh`, `down.sh`, `logs.sh`, `healthcheck.sh`, `hosts-subdomains.sh` (apply/remove), `dns-provision.sh` (dry-run).
- Modifies system state: `stepca-trust-install.sh`, `stepca-trust-uninstall.sh`, `dns-configure-ubuntu.sh`, `hosts-subdomains.sh` (when applied to `/etc/hosts`).
- Scripts that write files: `certs-selfsigned-generate.sh`, `traefik-render-dynamic.sh`, `certbot-issue.sh`.

## Troubleshooting

- Missing env var: check `.env` and `.env.example` for required keys.
- Docker/compose not found: install Docker and Compose v2, then retry.
- Permission denied (certs or trust store): re-run with `sudo` where required.
- Profile not enabled: use `COMPOSE_PROFILES=<profile> make up` when needed.

Useful commands:
```bash
make help
make ps
make logs
```
