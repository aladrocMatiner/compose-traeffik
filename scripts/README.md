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
- It enforces safe defaults for admin UIs (Traefik dashboard) and validates profile syntax.
- It also validates module-specific requirements for `ctfd`, `observability`, `plane`, and `docling` when those profiles are enabled, including optional integration toggles.
- When `AWX_ENABLED=true`, it validates AWX/k3d guardrails via `scripts/validate-awx-env.sh`.
- Create htpasswd files under `services/traefik/auth/`, for example:
  - `htpasswd -nbB admin 'change-me' > services/traefik/auth/traefik-dashboard.htpasswd`
- Set the container paths in `.env`:
  - `TRAEFIK_DASHBOARD_BASIC_AUTH_HTPASSWD_PATH=/etc/traefik/auth/traefik-dashboard.htpasswd`

## Script inventory

| Script | Purpose | Typical usage | Required env vars | Side effects |
| --- | --- | --- | --- | --- |
| `scripts/compose.sh` | Wrapper for layered compose files | `./scripts/compose.sh ps` | `.env` (via `--env-file`) | Runs docker compose |
| `scripts/up.sh` | Start the stack and render Traefik dynamic config | `make up` | none (loads `.env` if present) | Starts containers |
| `scripts/down.sh` | Stop the stack | `make down` | none | Stops containers |
| `scripts/logs.sh` | Follow service logs | `make logs` | none | Streams logs |
| `scripts/validate-env.sh` | Preflight validation for profiles and admin auth | `./scripts/validate-env.sh` | `COMPOSE_PROFILES`, `TRAEFIK_DASHBOARD_BASIC_AUTH_HTPASSWD_PATH`, `TRAEFIK_DASHBOARD` | Fails fast on unsafe config |
| `scripts/traefik-render-dynamic.sh` | Render Traefik dynamic config templates | `./scripts/traefik-render-dynamic.sh` | `DEV_DOMAIN` | Writes `services/traefik/dynamic-rendered` |
| `scripts/healthcheck.sh` | Run smoke tests | `make test` | `DEV_DOMAIN`, `HTTP_TO_HTTPS_REDIRECT` (fallback), `HTTP_TO_HTTPS_MIDDLEWARE` (preferred) | Runs tests, exits non-zero on failure |
| `scripts/certs-selfsigned-generate.sh` | Generate local CA + leaf certs | `make certs-local` | `DEV_DOMAIN`, `CA_SUBJECT_*`, `LEAF_*` | Writes `shared/certs/local-ca` and `shared/certs/local` |
| `scripts/certbot-issue.sh` | Issue LE certs (profile `le`) | `make certs-le-issue` | `DEV_DOMAIN`, `ACME_EMAIL`, `LETSENCRYPT_STAGING` | Runs certbot container, writes `services/certbot/conf` |
| `scripts/certbot-renew.sh` | Renew LE certs (profile `le`) | `make certs-le-renew` | `LETSENCRYPT_STAGING` | Runs certbot renew |
| `scripts/stepca-bootstrap.sh` | Bootstrap step-ca (profile `stepca`) | `make stepca-bootstrap` | `DEV_DOMAIN`, `CA_NAME`/`STEP_CA_NAME`, `CA_DNS`/`CA_IPS` (or `STEP_CA_DNS`), `STEP_CA_ADMIN_PROVISIONER_PASSWORD`, `STEP_CA_PASSWORD` | Initializes step-ca data |
| `scripts/stepca-trust-install.sh` | Install step-ca root cert (Ubuntu 24.04) | `sudo make stepca-trust-install` | `STEPCA_CA_CERT_PATH` (optional) | Writes to system trust store |
| `scripts/stepca-trust-uninstall.sh` | Remove step-ca root cert (Ubuntu 24.04) | `sudo make stepca-trust-uninstall` | none | Removes system trust entry |
| `scripts/stepca-trust-verify.sh` | Verify step-ca root trust (Ubuntu 24.04) | `make stepca-trust-verify` | `STEPCA_CA_CERT_PATH` (optional) | Reads system trust store |
| `scripts/ca-config-verify.sh` | Validate shared CA configuration | `./scripts/ca-config-verify.sh` | `DEV_DOMAIN`, `CA_*`, `LEAF_*` (or legacy `STEP_CA_*`) | Prints effective CA configuration |
| `scripts/hosts-subdomains.sh` | Manage hosts block for loopback subdomains | `make hosts-apply` | `BASE_DOMAIN`, `LOOPBACK_X` | Modifies hosts file (with sudo) |
| `scripts/bind-provision.sh` | Generate BIND zone file from ENDPOINTS | `make bind-provision` | `BASE_DOMAIN`, `LOOPBACK_X`, `ENDPOINTS` | Writes `services/dns-bind/zones` |
| `scripts/awx-bootstrap.sh` | Generate/persist AWX bootstrap secrets and defaults | `make awx-bootstrap` | `AWX_*`, `K3D_*` | Writes `.env` values |
| `scripts/awx-k3d-up.sh` | Create/ensure local k3d cluster for AWX | `make awx-k3d-up` | `AWX_K3D_CLUSTER_NAME`, `AWX_*`, `K3D_K3S_IMAGE` | Creates local k3d cluster, writes kubeconfig |
| `scripts/awx-k3d-down.sh` | Delete local k3d cluster for AWX | `make awx-k3d-down` | `AWX_K3D_CLUSTER_NAME` | Deletes local k3d cluster |
| `scripts/awx-up.sh` | Install/upgrade AWX Operator and apply AWX instance | `make awx-up` | `AWX_*`, `K3D_*`, `DEV_DOMAIN` | Applies Kubernetes resources, renders Traefik AWX route |
| `scripts/awx-down.sh` | Delete AWX instance (keeps cluster) | `make awx-down` | `AWX_*` | Deletes AWX CR |
| `scripts/awx-status.sh` | Show AWX/operator cluster status | `make awx-status` | `AWX_*` | Reads Kubernetes resources |
| `scripts/awx-logs.sh` | List/follow AWX/operator logs | `make awx-logs [ROLE=...]` | `AWX_*` | Streams pod logs |
| `scripts/awx-admin-password.sh` | Print AWX admin password from Kubernetes secret | `make awx-admin-password` | `AWX_*` | Reads secret value |
| `scripts/awx-debug.sh` | Collect AWX operator/web/task snapshots and recent logs into a local bundle | `make awx-debug` | `AWX_*` | Writes `.local/awx/debug/...` |
| `scripts/awx-backup.sh` | Create operator-managed `AWXBackup` CR and save local metadata bundle | `make awx-backup` | `AWX_*` | Creates `AWXBackup` CR, writes `.local/awx/backups/...` |
| `scripts/awx-restore.sh` | Create `AWXRestore` CR from an existing backup (requires explicit confirmation) | `make awx-restore AWX_RESTORE_ARGS='--backup-name <name> --confirm'` | `AWX_*` | Creates `AWXRestore` CR, writes restore metadata bundle |
| `scripts/awx-upgrade.sh` | Reapply/upgrade operator + AWX target pins (requires explicit confirmation) | `make awx-upgrade AWX_UPGRADE_ARGS='--confirm [--operator-chart-version ...] [--awx-version-target ...]'` | `AWX_*` | Updates `.env` pins and reapplies AWX |
| `scripts/validate-awx-env.sh` | Validate AWX/k3d env inputs before AWX lifecycle ops | `./scripts/validate-awx-env.sh` | `AWX_*`, `K3D_*` | Fails fast on invalid values |
| `scripts/ctfd-bootstrap.sh` | Generate/persist CTFd secrets in `.env` | `make ctfd-bootstrap` | `CTFD_*` (writes missing values) | Updates `.env` |
| `scripts/observability-bootstrap.sh` | Generate/persist Grafana secrets in `.env` | `make observability-bootstrap` | `GRAFANA_*` (writes missing values) | Updates `.env` |
| `scripts/plane-bootstrap.sh` | Generate/persist Plane secrets in `.env` | `make plane-bootstrap` | `PLANE_*` (writes missing values) | Updates `.env` |
| `scripts/docling-bootstrap.sh` | Generate/persist Docling secrets in `.env` | `make docling-bootstrap` | `DOCLING_*` (writes missing values) | Updates `.env` |
| `scripts/common.sh` | Shared helpers | sourced by other scripts | none | none |

## Workflows

### Standard lifecycle

```bash
make up
make logs
make test
make down
```

### BIND lifecycle

```bash
make bind-provision
make bind-up
make bind-status
make bind-restart
make bind-logs
make bind-down
```

### AWX (k3d hybrid module)

```bash
make awx-bootstrap
make awx-k3d-up
make awx-up
make awx-status
make awx-admin-password
make awx-debug
make awx-backup
# restore/upgrade require explicit confirmation flags:
# make awx-restore AWX_RESTORE_ARGS="--backup-name awx-backup-... --confirm"
# make awx-upgrade AWX_UPGRADE_ARGS="--confirm --operator-chart-version 3.2.0"
```

### CTFd module

```bash
make ctfd-bootstrap
make ctfd-up
make ctfd-status
make ctfd-logs
```

### Observability module

```bash
make observability-bootstrap
make observability-up
make observability-status
make observability-logs
make observability-k6
```

### Plane module

```bash
make plane-bootstrap
make plane-up
make plane-status
make plane-logs
```

### Docling module

```bash
make docling-bootstrap
make docling-up
make docling-status
make docling-logs
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

- Safe to rerun: `up.sh`, `down.sh`, `logs.sh`, `healthcheck.sh`, `hosts-subdomains.sh` (apply/remove).
- Modifies system state: `stepca-trust-install.sh`, `stepca-trust-uninstall.sh`, `hosts-subdomains.sh` (when applied to `/etc/hosts`).
- Scripts that write files: `certs-selfsigned-generate.sh`, `traefik-render-dynamic.sh`, `certbot-issue.sh`.
- AWX scripts write local artifacts under `.local/` (gitignored) and repo-rendered manifests under `services/awx/k8s/rendered/`.
- AWX day-2 scripts (`awx-restore`, `awx-upgrade`) require explicit `--confirm` to reduce accidental destructive operations.
- `awx-backup` stores an operator-managed backup in-cluster (backup PVC) and writes a local metadata bundle with backup identifiers for restore workflows.

## Troubleshooting

- Missing env var: check `.env` and `.env.example` for required keys.
- Docker/compose not found: install Docker and Compose v2, then retry.
- Permission denied (certs or trust store): re-run with `sudo` where required.
- Profile not enabled: use `COMPOSE_PROFILES=<profile> make up` when needed.
- BIND exposed on non-loopback: set `BIND_ALLOW_NONLOCAL_BIND=true` explicitly if this is intentional.
- AWX restore/upgrade blocked: pass explicit `AWX_RESTORE_ARGS='... --confirm'` or `AWX_UPGRADE_ARGS='--confirm ...'` after reviewing the runbook.

Useful commands:
```bash
make help
make ps
make logs
```
