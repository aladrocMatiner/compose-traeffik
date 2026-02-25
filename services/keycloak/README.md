[English](README.md) | [Svenska](README.sv.md) | [Espanol](README.es.md)

# Keycloak service

<a id="overview"></a>
## Overview

Keycloak runs as an optional module (`profile: keycloak`) behind Traefik with PostgreSQL as an internal dependency. TLS terminates at Traefik; Keycloak is configured for reverse-proxy headers.

<a id="location"></a>
## Where it lives

- `services/keycloak/compose.yml` (Keycloak + Postgres)
- `services/keycloak/observability/README.md` (optional observability hooks/app-pack notes)
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

Relevant `.env` variables:
- `KEYCLOAK_IMAGE`
- `KEYCLOAK_HOSTNAME`
- `KEYCLOAK_ADMIN_USER`
- `KEYCLOAK_ADMIN_PASSWORD`
- `KEYCLOAK_DB_NAME`, `KEYCLOAK_DB_USER`, `KEYCLOAK_DB_PASSWORD`, `KEYCLOAK_DB_PORT`
- `KEYCLOAK_PROXY_HEADERS` (`xforwarded` recommended for Traefik)
- `KEYCLOAK_HEALTH_ENABLED`
- `KEYCLOAK_MANAGEMENT_PORT`
- `KEYCLOAK_OBSERVABILITY_ENABLED`
- `KEYCLOAK_OBSERVABILITY_DISCOVERY`
- `KEYCLOAK_OBSERVABILITY_PUBLIC_METRICS` (must remain `false` by default)

<a id="ports"></a>
## Ports, networks, volumes

- Public endpoint: `https://keycloak.<DEV_DOMAIN>` via Traefik
- Keycloak main HTTP port (`8080`) and management port (`9000`) are internal-only by default (no host port publishing)
- Postgres is internal-only on `keycloak-internal`
- Persistent volume: `keycloak-db-data`

<a id="security"></a>
## Security notes

- Access Keycloak through Traefik/TLS; do not publish Keycloak ports directly by default.
- Bootstrap secrets are stored in `.env`; do not commit them.
- `KEYCLOAK_PROXY_HEADERS` must be set for reverse proxy deployments.
- Observability metrics are intended for internal scraping only; no public metrics router is created by default.

<a id="troubleshooting"></a>
## Troubleshooting

- Bootstrap secrets: `make keycloak-bootstrap`
- Validate env/guardrails: `COMPOSE_PROFILES=keycloak ./scripts/validate-env.sh`
- Check service status: `make keycloak-status`
- Test login page via Traefik:
  - `curl -skI --resolve keycloak.<DEV_DOMAIN>:443:127.0.0.1 https://keycloak.<DEV_DOMAIN>/`
- Health/metrics (internal only): use `docker exec keycloak ...` or internal network checks; do not expose publicly by default.

Manual runtime validation checklist:
- `make keycloak-bootstrap`
- `make keycloak-up`
- `make keycloak-status` until healthy
- Open `https://keycloak.<DEV_DOMAIN>` (or curl with `--resolve`)
- Verify admin console/login page renders
- Optional auth sanity: attempt token endpoint or admin login using bootstrap credentials
- If observability is enabled, confirm `/metrics` is reachable only on the internal management interface path (not public Traefik)

<a id="related"></a>
## Related pages

- [Root README](../../README.md)
- [Traefik](../traefik/README.md)
- [Observability hooks](observability/README.md)
