[English](README.md) | [Svenska](README.sv.md) | [Espanol](README.es.md)

# Keycloak-tjanst

<a id="overview"></a>
## Overview

Keycloak kor som en valfri modul (`profile: keycloak`) bakom Traefik med PostgreSQL som intern beroende. TLS termineras i Traefik och Keycloak konfigureras for reverse proxy.

<a id="location"></a>
## Where it lives

- `services/keycloak/compose.yml` (Keycloak + Postgres)
- `services/keycloak/observability/README.md` (valfria observability-noter)
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

Relevanta variabler i `.env`:
- `KEYCLOAK_IMAGE`
- `KEYCLOAK_HOSTNAME`
- `KEYCLOAK_ADMIN_USER`, `KEYCLOAK_ADMIN_PASSWORD`
- `KEYCLOAK_DB_NAME`, `KEYCLOAK_DB_USER`, `KEYCLOAK_DB_PASSWORD`, `KEYCLOAK_DB_PORT`
- `KEYCLOAK_PROXY_HEADERS`
- `KEYCLOAK_HEALTH_ENABLED`, `KEYCLOAK_MANAGEMENT_PORT`
- `KEYCLOAK_OBSERVABILITY_ENABLED`, `KEYCLOAK_OBSERVABILITY_DISCOVERY`
- `KEYCLOAK_OBSERVABILITY_PUBLIC_METRICS` (ska vara `false` som standard)

<a id="ports"></a>
## Ports, networks, volumes

- Publik endpoint: `https://keycloak.<DEV_DOMAIN>` via Traefik
- Interna portar som standard: Keycloak `8080` och management `9000` (inga host-portar)
- Postgres ar intern pa `keycloak-internal`
- Persistensvolym: `keycloak-db-data`

<a id="security"></a>
## Security

- Anvand Traefik/TLS; exponera inte Keycloak-portar direkt som standard.
- Bootstrap-hemligheter lagras i `.env` och ska inte committas.
- `KEYCLOAK_PROXY_HEADERS` kravs bakom reverse proxy.
- Observability-metrik ar for intern scraping; ingen publik metrics-router skapas som standard.

<a id="troubleshooting"></a>
## Troubleshooting

- `make keycloak-bootstrap`
- `COMPOSE_PROFILES=keycloak ./scripts/validate-env.sh`
- `make keycloak-status`
- `curl -skI --resolve keycloak.<DEV_DOMAIN>:443:127.0.0.1 https://keycloak.<DEV_DOMAIN>/`

Manuell runtime-checklista:
- bootstrap + up + status
- verifiera login/admin-sida
- enkel auth/token-test (valfritt)
- om observability ar aktiv, kontrollera att `/metrics` inte ar publikt exponerad via Traefik

<a id="related"></a>
## Related pages

- [Root README](../../README.sv.md)
- [Traefik](../traefik/README.sv.md)
- [Observability hooks](observability/README.sv.md)
