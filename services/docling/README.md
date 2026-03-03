[English](README.md) | [Svenska](README.sv.md) | [Espanol](README.es.md)

# Docling service

<a id="overview"></a>
## Overview

Docling is an optional document-conversion API module exposed behind Traefik. This module runs `docling-serve` plus an internal Redis dependency for optional RQ/async engine modes.

<a id="location"></a>
## Where it lives

- `services/docling/compose.yml`

<a id="run"></a>
## How it runs

```bash
make docling-bootstrap
make docling-up
make docling-status
```

URL (when routed via Traefik): `https://docling.${DEV_DOMAIN}`

<a id="configuration"></a>
## Configuration

Relevant env vars in `.env.example`:
- `DOCLING_HOSTNAME`
- `DOCLING_IMAGE`, `DOCLING_IMAGE_TAG`, `DOCLING_REDIS_IMAGE`
- `DOCLING_ENABLE_UI`
- `DOCLING_ENGINE_KIND`
- `DOCLING_API_KEY`
- `DOCLING_REDIS_PASSWORD`
- `DOCLING_UVICORN_ROOT_PATH`
- `DOCLING_MAX_SYNC_WAIT`

Optional integrations:
- Keycloak contract: `DOCLING_KEYCLOAK_*`, `DOCLING_AUTH_MODE`, `DOCLING_TRAEFIK_MIDDLEWARES`
- Observability hooks: `DOCLING_OBSERVABILITY_*`, `DOCLING_SERVE_OTEL_*`, `DOCLING_OTEL_EXPORTER_OTLP_ENDPOINT`

Secrets can be generated/persisted with `make docling-bootstrap`.

<a id="ports"></a>
## Ports, networks, volumes

- Public ports: none (Traefik handles public exposure)
- Networks:
  - `proxy` (Docling app only, for Traefik routing)
  - `docling-internal` (app/cache traffic)
- Volumes:
  - `docling-artifacts`
  - `docling-scratch`
  - `docling-model-cache`
  - `docling-redis-data`

<a id="security"></a>
## Security notes

- Docling and Redis do not publish host ports by default.
- API/UI is exposed only through Traefik HTTPS routing.
- Redis is isolated on an internal network.
- TLS mode compatibility is inherited from `TLS_CERT_RESOLVER` (Mode A/B/C, including Step-CA mode).
- Preflight checks are profile-gated and only enforce Docling checks when `docling` profile is enabled.

<a id="troubleshooting"></a>
## Troubleshooting

- If preflight fails due to secrets, run:
  - `make docling-bootstrap`
- If startup loops, inspect container health/logs:
  - `make docling-logs`
- If Keycloak integration is enabled, ensure all `DOCLING_KEYCLOAK_*` values are set.

<a id="related"></a>
## Related pages

- [Root README](../../README.md)
- [Traefik](../traefik/README.md)
- [Observability](../observability/README.md)
