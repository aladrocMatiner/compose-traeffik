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
| `scripts/infra-provision.sh` | Provision/destroy deployment VMs (interface: `target=libvirt|qemu|proxmox`, `os=ubuntu|debian12|debian13|gentoo|opensuse-leap|almalinux9|rockylinux9|fedora-cloud`; Gentoo `init=openrc|systemd`; `debian` alias -> `debian13`) with Terraform + cloud-init | `make deployment`, `make deployment-destroy` | `DEPLOYMENT_*` / `PROXMOX_*` overrides (optional) | Creates/destroys VM resources, downloads/verifies cloud images for libvirt |
| `scripts/deployment-access.sh` | List/select deployment VMs by backend (`qemu` and `proxmox`) | `make deployment-list target=qemu`, `make deployment-list target=proxmox`, `make deployment-ssh target=<qemu\\|proxmox> name=<vm>` | `DEPLOYMENT_MANAGED_PREFIX`, optional `DEPLOYMENT_SSH_USER`, for proxmox `PROXMOX_API_URL` + `PROXMOX_API_TOKEN` | Reads hypervisor inventory and opens SSH |
| `scripts/host-wait-ssh.sh` | Wait for SSH reachability and cloud-init completion on a provisioned VM | `make deployment-wait` | Terraform state (default) or host/user args | Waits/polls remote host |
| `scripts/host-bootstrap.sh` | Install Docker Engine + Compose plugin over SSH on a provisioned Ubuntu/Debian (12/13) VM | `make deployment-bootstrap` | Terraform state (default) or host/user args | Modifies remote host packages and Docker config |
| `scripts/host-bootstrap-check.sh` | Verify SSH/Python/Docker readiness on a provisioned Ubuntu/Debian (12/13) VM | `make deployment-bootstrap-check` | Terraform state (default) or host/user args | Reads remote host state |
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

### VM provisioning and host bootstrap (Phase 1)

```bash
make deployment                # provision Ubuntu VM (libvirt target, default)
make deployment os=ubuntu      # explicit selector syntax (implemented)
make deployment os=debian12    # Debian 12 qemu/libvirt image profile
make deployment os=debian13    # Debian 13 qemu/libvirt (implemented)
make deployment os=debian      # alias of debian13
make deployment os=gentoo      # Gentoo qemu/libvirt experimental (default init=openrc)
make deployment os=gentoo init=systemd  # explicit experimental variant selection
make deployment os=opensuse-leap
make deployment os=almalinux9
make deployment os=rockylinux9
make deployment os=fedora-cloud
make deployment target=proxmox os=ubuntu  # proxmox target (requires PROXMOX_* vars)
make deployment-wait           # wait for SSH + cloud-init
make deployment-output         # inspect outputs (IP, SSH user, metadata)
make deployment-ssh            # connect to the VM
make deployment-ssh target=qemu name=compose-traeffik-ubuntu
make deployment-list target=qemu
make deployment-list target=proxmox
make deployment-ssh target=proxmox name=compose-traeffik-ubuntu-pve
make deployment-bootstrap      # install Docker + Compose plugin
make deployment-bootstrap-check
make deployment-ready          # end-to-end provisioning + Docker-ready host
```

Notes:
- `init=` is only valid with `os=gentoo`.
- `target=qemu` is a UX alias for `target=libvirt`.
- `target=proxmox` currently supports `os=ubuntu` in the provisioning wrapper.
- `deployment-access.sh` for `target=proxmox` requires API credentials (`PROXMOX_API_URL`, `PROXMOX_API_TOKEN`) and resolves IP via guest-agent when possible.
- Docker bootstrap/check scripts currently support `ubuntu`, `debian12` and `debian13`.
- Gentoo provisioning is experimental; Docker bootstrap/check for Gentoo are not implemented in these scripts.

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

## Troubleshooting

- Missing env var: check `.env` and `.env.example` for required keys.
- Docker/compose not found: install Docker and Compose v2, then retry.
- Permission denied (certs or trust store): re-run with `sudo` where required.
- Profile not enabled: use `COMPOSE_PROFILES=<profile> make up` when needed.
- BIND exposed on non-loopback: set `BIND_ALLOW_NONLOCAL_BIND=true` explicitly if this is intentional.

Useful commands:
```bash
make help
make ps
make logs
```
