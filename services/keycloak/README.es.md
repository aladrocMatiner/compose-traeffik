[English](README.md) | [Svenska](README.sv.md) | [Espanol](README.es.md)

# Servicio Keycloak

<a id="overview"></a>
## Overview

Keycloak se ejecuta como modulo opcional (`profile: keycloak`) detras de Traefik con PostgreSQL como dependencia interna. TLS termina en Traefik y Keycloak se configura para proxy inverso.

<a id="location"></a>
## Where it lives

- `services/keycloak/compose.yml` (Keycloak + Postgres)
- `services/keycloak/observability/README.md` (notas de observabilidad opcional)
- `scripts/keycloak-bootstrap.sh`

<a id="run"></a>
## How it runs

```bash
make keycloak-bootstrap
make keycloak-up
make keycloak-status
make keycloak-logs
```

<a id="configuration"></a>
## Configuration

Variables relevantes en `.env`:
- `KEYCLOAK_IMAGE`
- `KEYCLOAK_HOSTNAME`
- `KEYCLOAK_ADMIN_USER`, `KEYCLOAK_ADMIN_PASSWORD`
- `KEYCLOAK_DB_NAME`, `KEYCLOAK_DB_USER`, `KEYCLOAK_DB_PASSWORD`, `KEYCLOAK_DB_PORT`
- `KEYCLOAK_PROXY_HEADERS`
- `KEYCLOAK_HEALTH_ENABLED`, `KEYCLOAK_MANAGEMENT_PORT`
- `KEYCLOAK_OBSERVABILITY_ENABLED`, `KEYCLOAK_OBSERVABILITY_DISCOVERY`
- `KEYCLOAK_OBSERVABILITY_PUBLIC_METRICS` (debe permanecer `false` por defecto)

<a id="ports"></a>
## Ports, networks, volumes

- Endpoint publico: `https://keycloak.<DEV_DOMAIN>` via Traefik
- Puertos internos por defecto: Keycloak `8080` y management `9000` (sin publicacion al host)
- Postgres interno en `keycloak-internal`
- Volumen persistente: `keycloak-db-data`

<a id="security"></a>
## Security

- Usar acceso via Traefik/TLS; no publicar puertos de Keycloak por defecto.
- Los secretos bootstrap se guardan en `.env` y no deben versionarse.
- `KEYCLOAK_PROXY_HEADERS` es necesario para despliegue detras de proxy.
- Las metricas de observabilidad son para scraping interno; no se crea router publico por defecto.

<a id="troubleshooting"></a>
## Troubleshooting

- `make keycloak-bootstrap`
- `COMPOSE_PROFILES=keycloak ./scripts/validate-env.sh`
- `make keycloak-status`
- `curl -skI --resolve keycloak.<DEV_DOMAIN>:443:127.0.0.1 https://keycloak.<DEV_DOMAIN>/`

Checklist runtime manual:
- bootstrap + up + status
- comprobar pagina de login/admin
- prueba basica de auth/token (opcional)
- si observabilidad esta activa, confirmar que `/metrics` no esta expuesto publicamente por Traefik

<a id="related"></a>
## Related pages

- [Root README](../../README.es.md)
- [Traefik](../traefik/README.es.md)
- [Observability hooks](observability/README.es.md)
