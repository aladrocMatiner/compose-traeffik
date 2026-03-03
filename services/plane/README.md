[English](README.md) | [Svenska](README.sv.md) | [Espanol](README.es.md)

# Plane service

<a id="overview"></a>
## Overview

Plane is an optional project-management module exposed behind Traefik. This module runs Plane app services plus internal PostgreSQL, Redis (Valkey), RabbitMQ, and MinIO dependencies.

<a id="location"></a>
## Where it lives

- `services/plane/compose.yml`

<a id="run"></a>
## How it runs

```bash
make plane-bootstrap
make plane-up
make plane-status
```

URL (when routed via Traefik): `https://plane.${DEV_DOMAIN}`

<a id="configuration"></a>
## Configuration

Relevant env vars in `.env.example`:
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

Optional integrations:
- Keycloak/OIDC contract: `PLANE_OIDC_*`, `PLANE_KEYCLOAK_*`
- Observability hooks: `PLANE_OBSERVABILITY_*`, `PLANE_OTEL_*`

Bootstrap secrets with `make plane-bootstrap`.

<a id="ports"></a>
## Ports, networks, volumes

- Public ports: none (Traefik handles public exposure)
- Networks:
  - `proxy` (Plane web service only)
  - `plane-internal` (app/dependency traffic)
- Volumes:
  - `plane-pgdata`
  - `plane-redisdata`
  - `plane-rabbitmq-data`
  - `plane-uploads`
  - `plane-logs-api`
  - `plane-logs-worker`
  - `plane-logs-beat-worker`
  - `plane-logs-migrator`

<a id="security"></a>
## Security notes

- Plane dependencies do not publish host ports by default.
- The UI is exposed only through Traefik HTTPS routing.
- Database/cache/message-broker/object-store are isolated on an internal network.
- TLS mode compatibility is inherited from `TLS_CERT_RESOLVER` (Mode A/B/C, including Step-CA mode).
- Preflight checks are profile-gated and only enforce Plane-specific checks when `plane` profile is enabled.

<a id="troubleshooting"></a>
## Troubleshooting

- If preflight fails, generate missing secrets:
  - `make plane-bootstrap`
- If startup loops, inspect readiness chain:
  - `make plane-logs`
- If OIDC is enabled, ensure the full `PLANE_OIDC_*` contract is set.
- If using local Keycloak profile later, use `PLANE_KEYCLOAK_MODE=local` with `PLANE_KEYCLOAK_INTERNAL_URL`.

<a id="related"></a>
## Related pages

- [Root README](../../README.md)
- [Traefik](../traefik/README.md)
- [Observability](../observability/README.md)
