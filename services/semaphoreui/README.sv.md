[English](README.md) | [Svenska](README.sv.md) | [Espanol](README.es.md)

# Semaphore UI-tjanst

<a id="overview"></a>
## Overview

Semaphore UI ger ett webbgranssnitt och API for automation med Ansible/Terraform/OpenTofu. I detta repo kor den bakom Traefik med intern PostgreSQL.

<a id="location"></a>
## Where it lives

- `services/semaphoreui/compose.yml`
- `services/semaphoreui/observability/README.sv.md`

<a id="run"></a>
## How it runs

```bash
make semaphoreui-bootstrap
make semaphoreui-up
make semaphoreui-status
```

<a id="configuration"></a>
## Configuration

Relevanta `.env`-variabler:
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

OIDC/Keycloak-exempel:
- In-repo/framtida Keycloak-hostname: `SEMAPHOREUI_OIDC_PROVIDER_URL=https://keycloak.${DEV_DOMAIN}/realms/<realm>`
- Extern Keycloak: `SEMAPHOREUI_OIDC_PROVIDER_URL=https://<keycloak-host>/realms/<realm>`

<a id="ports"></a>
## Ports, networks, volumes

- Semaphore UI: containerport `3000` (inte publicerad till host)
- PostgreSQL: containerport `5432` (endast intern; inte publicerad)
- Natverk: `proxy` och `semaphoreui-internal`
- Volymer: `semaphoreui-db-data`

<a id="security"></a>
## Security notes

- UI/API exponeras endast via Traefik som standard.
- PostgreSQL ar intern som standard.
- OIDC/Keycloak ar valfritt och avstangt som standard.
- Observability ar valfritt och avstangt som standard; ingen publik telemetri exponeras som standard.

<a id="troubleshooting"></a>
## Troubleshooting

- Kor `make semaphoreui-logs` och `make semaphoreui-status`.
- Verifiera att `https://semaphore.${DEV_DOMAIN}` pekar till Traefik (hosts/DNS).
- Om OIDC ar aktiverat, kontrollera issuer/provider URL, client ID/secret och HTTPS-hostname.
- Testa API ping via Traefik: `https://semaphore.${DEV_DOMAIN}/api/ping`.

<a id="related"></a>
## Related pages

- [Root README](../../README.sv.md)
- [Traefik](../traefik/README.sv.md)
- [Semaphore UI observability](observability/README.sv.md)
