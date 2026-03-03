[English](README.md) | [Svenska](README.sv.md) | [Espanol](README.es.md)

# Docling service

<a id="overview"></a>
## Oversikt

Docling ar en valfri dokumentkonverteringsmodul exponerad bakom Traefik. Modulen kor `docling-serve` med ett internt Redis-beroende for valfria RQ/async-lagen.

<a id="location"></a>
## Var den finns

- `services/docling/compose.yml`

<a id="run"></a>
## Hur den kor

```bash
make docling-bootstrap
make docling-up
make docling-status
```

URL (via Traefik): `https://docling.${DEV_DOMAIN}`

<a id="configuration"></a>
## Konfiguration

Relevanta env vars i `.env.example`:
- `DOCLING_HOSTNAME`
- `DOCLING_IMAGE`, `DOCLING_IMAGE_TAG`, `DOCLING_REDIS_IMAGE`
- `DOCLING_ENABLE_UI`
- `DOCLING_ENGINE_KIND`
- `DOCLING_API_KEY`
- `DOCLING_REDIS_PASSWORD`
- `DOCLING_UVICORN_ROOT_PATH`
- `DOCLING_MAX_SYNC_WAIT`

Valfria integrationer:
- Keycloak-kontrakt: `DOCLING_KEYCLOAK_*`, `DOCLING_AUTH_MODE`, `DOCLING_TRAEFIK_MIDDLEWARES`
- Observability hooks: `DOCLING_OBSERVABILITY_*`, `DOCLING_SERVE_OTEL_*`, `DOCLING_OTEL_EXPORTER_OTLP_ENDPOINT`

Skapa secrets med `make docling-bootstrap`.

<a id="ports"></a>
## Portar, natverk, volymer

- Publika portar: inga (Traefik exponerar API/UI)
- Natverk:
  - `proxy` (endast Docling app)
  - `docling-internal` (app/cache-trafik)
- Volymer:
  - `docling-artifacts`
  - `docling-scratch`
  - `docling-model-cache`
  - `docling-redis-data`

<a id="security"></a>
## Sakerhetsnoter

- Docling och Redis publicerar inga host-portar som standard.
- API/UI exponeras endast via Traefik over HTTPS.
- Redis isoleras i internt natverk.
- TLS-kompatibilitet arvs via `TLS_CERT_RESOLVER` (Mode A/B/C, inklusive Step-CA).
- Preflight ar profile-gated och verifierar Docling endast nar `docling`-profilen ar aktiv.

<a id="troubleshooting"></a>
## Felsokning

- Om preflight faller pa secrets, kor:
  - `make docling-bootstrap`
- Vid omstarter, kontrollera health/loggar:
  - `make docling-logs`
- Om Keycloak aktiveras, fyll `DOCLING_KEYCLOAK_*`.

<a id="related"></a>
## Relaterade sidor

- [Root README](../../README.sv.md)
- [Traefik](../traefik/README.sv.md)
- [Observability](../observability/README.sv.md)
