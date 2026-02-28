# Deployment Scripts

This directory contains scripts used by the `make deployment-*` workflow.

- `infra-provision.sh`
- `infra-validate.sh`
- `deployment-access.sh`
- `deployment-project.sh`
- `host-wait-ssh.sh`
- `host-bootstrap.sh`
- `host-bootstrap-check.sh`

`Makefile` resolves them through `DEPLOYMENT_SCRIPTS_DIR`.

Project orchestration entrypoints:

- `make deployment-project-list` -> `deployment-project.sh list`
- `make deployment-project project=<id> [target=<qemu>] [os=<ubuntu>] [tls_mode=<stepca-acme|letsencrypt-acme>]`

Current catalog projects:

- `traefik-stepca`
- `traefik-keycloak`
- `traefik-observability`
- `traefik-wikijs`
- `traefik-semaphoreui`

`traefik-observability` contract highlights:

- defaults to `tls_mode=stepca-acme` (override allowed with `tls_mode=...`)
- depends on `traefik-stepca` and `traefik-keycloak`
- requires `KEYCLOAK_FORWARDAUTH_ADDRESS` to wire Keycloak-based forward auth for Grafana

`traefik-wikijs` contract highlights:

- defaults to `tls_mode=stepca-acme` (override allowed with `tls_mode=...`)
- depends on `traefik-stepca` and `traefik-keycloak`
- configures Keycloak OIDC contract for Wiki.js (`realm=local.test`, `client_id=wikijs`) during deployment

`traefik-semaphoreui` contract highlights:

- defaults to `tls_mode=stepca-acme` (override allowed with `tls_mode=...`)
- depends on `traefik-stepca` and `traefik-keycloak`
- configures Keycloak OIDC contract for Semaphore UI (`realm=local.test`, `client_id=semaphoreui`) during deployment

Hostname contract for web projects:

- Default public host: `<project-id>.<BASE_DOMAIN>`
- Optional manifest override: `public_host`

Terraform state isolation:

- `deployment-project` uses one tfstate per VM/project under `infra/terraform/state/<target>/<vm-name>.tfstate`.
- This allows running multiple project VMs in parallel (for example: stepca + keycloak + observability).
