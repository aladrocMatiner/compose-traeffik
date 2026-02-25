[English](README.md) | [Svenska](README.sv.md) | [Espanol](README.es.md)

# Servicio Semaphore UI

<a id="overview"></a>
## Overview

Semaphore UI ofrece una interfaz web y API para automatizacion con Ansible/Terraform/OpenTofu. En este repositorio se ejecuta detras de Traefik con PostgreSQL interno.

<a id="location"></a>
## Where it lives

- `services/semaphoreui/compose.yml`
- `services/semaphoreui/observability/README.es.md`

<a id="run"></a>
## How it runs

```bash
make semaphoreui-bootstrap
make semaphoreui-up
make semaphoreui-status
```

<a id="configuration"></a>
## Configuration

Variables relevantes en `.env`:
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

Ejemplos OIDC/Keycloak:
- Keycloak en el repo/futuro: `SEMAPHOREUI_OIDC_PROVIDER_URL=https://keycloak.${DEV_DOMAIN}/realms/<realm>`
- Keycloak externo: `SEMAPHOREUI_OIDC_PROVIDER_URL=https://<keycloak-host>/realms/<realm>`

<a id="ports"></a>
## Ports, networks, volumes

- Semaphore UI: puerto de contenedor `3000` (sin publicar al host)
- PostgreSQL: puerto de contenedor `5432` (solo interno; sin publicar)
- Redes: `proxy` y `semaphoreui-internal`
- Volumenes: `semaphoreui-db-data`

<a id="security"></a>
## Security notes

- La UI/API se expone solo por Traefik por defecto.
- PostgreSQL es interno por defecto.
- La integracion OIDC/Keycloak es opcional y viene desactivada por defecto.
- La observabilidad es opcional y desactivada por defecto; no hay telemetria publica por defecto.

<a id="troubleshooting"></a>
## Troubleshooting

- Ejecuta `make semaphoreui-logs` y `make semaphoreui-status`.
- Verifica que `https://semaphore.${DEV_DOMAIN}` resuelva hacia Traefik (hosts/DNS).
- Si OIDC esta activado, revisa issuer/provider URL, client ID/secret y hostname HTTPS.
- Prueba el ping de API por Traefik: `https://semaphore.${DEV_DOMAIN}/api/ping`.

<a id="related"></a>
## Related pages

- [Root README](../../README.es.md)
- [Traefik](../traefik/README.es.md)
- [Observabilidad de Semaphore UI](observability/README.es.md)
