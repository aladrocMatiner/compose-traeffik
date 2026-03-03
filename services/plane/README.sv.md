[English](README.md) | [Svenska](README.sv.md) | [Espanol](README.es.md)

# Plane service

<a id="overview"></a>
## Oversikt

Plane ar en valfri projektledningsmodul exponerad bakom Traefik. Modulen kor Plane-tjanster samt interna beroenden PostgreSQL, Redis (Valkey), RabbitMQ och MinIO.

<a id="location"></a>
## Var den finns

- `services/plane/compose.yml`

<a id="run"></a>
## Hur den kor

```bash
make plane-bootstrap
make plane-up
make plane-status
```

URL (via Traefik): `https://plane.${DEV_DOMAIN}`

<a id="configuration"></a>
## Konfiguration

Relevanta env vars i `.env.example`:
- `PLANE_HOSTNAME`
- `PLANE_APP_RELEASE`
- `PLANE_FRONTEND_IMAGE`
- `PLANE_SPACE_IMAGE`
- `PLANE_ADMIN_IMAGE`
- `PLANE_LIVE_IMAGE`
- `PLANE_BACKEND_IMAGE`
- `PLANE_POSTGRES_IMAGE`
- `PLANE_REDIS_IMAGE`
- `PLANE_RABBITMQ_IMAGE`
- `PLANE_MINIO_IMAGE`
- `PLANE_SECRET_KEY`
- `PLANE_LIVE_SERVER_SECRET_KEY`
- `PLANE_POSTGRES_PASSWORD`
- `PLANE_RABBITMQ_PASSWORD`
- `PLANE_AWS_SECRET_ACCESS_KEY`

Valfria integrationer:
- Keycloak/OIDC-kontrakt: `PLANE_OIDC_*`, `PLANE_KEYCLOAK_*`
- Observability hooks: `PLANE_OBSERVABILITY_*`, `PLANE_OTEL_*`

Skapa secrets med `make plane-bootstrap`.

<a id="ports"></a>
## Portar, natverk, volymer

- Publika portar: inga (Traefik exponerar UI)
- Natverk:
  - `proxy` (endast Plane web)
  - `plane-internal` (app/beroende-trafik)
- Volymer:
  - `plane-pgdata`
  - `plane-redisdata`
  - `plane-rabbitmq-data`
  - `plane-uploads`
  - `plane-logs-api`
  - `plane-logs-worker`
  - `plane-logs-beat-worker`
  - `plane-logs-migrator`

<a id="security"></a>
## Sakerhetsnoter

- Plane-beroenden publicerar inga host-portar som standard.
- UI exponeras endast via Traefik over HTTPS.
- DB/cache/message-broker/object-store isoleras i internt natverk.
- TLS-kompatibilitet arvs via `TLS_CERT_RESOLVER` (Mode A/B/C, inklusive Step-CA).
- Preflight ar profile-gated och verifierar Plane endast nar `plane`-profilen ar aktiv.

<a id="troubleshooting"></a>
## Felsokning

- Om preflight faller, skapa saknade secrets:
  - `make plane-bootstrap`
- Vid omstarter, kontrollera readiness-kedjan:
  - `make plane-logs`
- Om OIDC ar aktivt, fyll hela `PLANE_OIDC_*`-kontraktet.
- Om lokal Keycloak-profil anvands senare, satt `PLANE_KEYCLOAK_MODE=local` med `PLANE_KEYCLOAK_INTERNAL_URL`.

<a id="related"></a>
## Relaterade sidor

- [Root README](../../README.sv.md)
- [Traefik](../traefik/README.sv.md)
- [Observability](../observability/README.sv.md)
