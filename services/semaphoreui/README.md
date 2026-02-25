[English](README.md) | [Svenska](README.sv.md) | [Espanol](README.es.md)

# Semaphore UI service

<a id="overview"></a>
## Overview

Semaphore UI provides a web UI and API for running Ansible/Terraform/OpenTofu automation. In this repository it runs behind Traefik with an internal PostgreSQL database.

<a id="location"></a>
## Where it lives

- `services/semaphoreui/compose.yml`
- `services/semaphoreui/observability/README.md`

<a id="run"></a>
## How it runs

```bash
make semaphoreui-bootstrap
make semaphoreui-up
make semaphoreui-status
```

<a id="configuration"></a>
## Configuration

Relevant `.env` variables:
- `SEMAPHOREUI_HOSTNAME`
- `SEMAPHOREUI_IMAGE`
- `SEMAPHOREUI_ADMIN_*`
- `SEMAPHOREUI_DB_*`
- `SEMAPHOREUI_COOKIE_HASH`
- `SEMAPHOREUI_COOKIE_ENCRYPTION`
- `SEMAPHOREUI_ACCESS_KEY_ENCRYPTION`
- `SEMAPHOREUI_OIDC_ENABLED`, `SEMAPHOREUI_OIDC_*`
- `SEMAPHOREUI_OBSERVABILITY_*`
- `DEV_DOMAIN`, `TLS_CERT_RESOLVER`

OIDC/Keycloak examples:
- In-repo/future Keycloak hostname: `SEMAPHOREUI_OIDC_PROVIDER_URL=https://keycloak.${DEV_DOMAIN}/realms/<realm>`
- External Keycloak: `SEMAPHOREUI_OIDC_PROVIDER_URL=https://<keycloak-host>/realms/<realm>`

<a id="ports"></a>
## Ports, networks, volumes

- Semaphore UI: container port `3000` (not published to host)
- PostgreSQL: container port `5432` (internal only; not published)
- Networks: `proxy` and `semaphoreui-internal`
- Volumes: `semaphoreui-db-data`

<a id="security"></a>
## Security notes

- UI/API is exposed only through Traefik by default.
- PostgreSQL is internal-only by default.
- OIDC/Keycloak integration is optional and disabled by default.
- Observability integration is optional and disabled by default; no public telemetry endpoint is exposed by default.

<a id="troubleshooting"></a>
## Troubleshooting

- Run `make semaphoreui-logs` and `make semaphoreui-status`.
- Verify `https://semaphore.${DEV_DOMAIN}` resolves to Traefik (hosts/DNS).
- If OIDC is enabled, check issuer/provider URL, client ID/secret, and HTTPS hostname match.
- Test the API ping endpoint through Traefik: `https://semaphore.${DEV_DOMAIN}/api/ping`.

<a id="related"></a>
## Related pages

- [Root README](../../README.md)
- [Traefik](../traefik/README.md)
- [Semaphore UI observability](observability/README.md)
