[English](README.md) | [Svenska](README.sv.md) | [Espanol](README.es.md)

# Docling service

<a id="overview"></a>
## Resumen

Docling es un modulo opcional de conversion de documentos expuesto detras de Traefik. Este modulo ejecuta `docling-serve` con una dependencia interna Redis para modos opcionales RQ/async.

<a id="location"></a>
## Donde vive

- `services/docling/compose.yml`

<a id="run"></a>
## Como corre

```bash
make docling-bootstrap
make docling-up
make docling-status
```

URL (via Traefik): `https://docling.${DEV_DOMAIN}`

<a id="configuration"></a>
## Configuracion

Variables relevantes en `.env.example`:
- `DOCLING_HOSTNAME`
- `DOCLING_IMAGE`, `DOCLING_IMAGE_TAG`, `DOCLING_REDIS_IMAGE`
- `DOCLING_ENABLE_UI`
- `DOCLING_ENGINE_KIND`
- `DOCLING_API_KEY`
- `DOCLING_REDIS_PASSWORD`
- `DOCLING_UVICORN_ROOT_PATH`
- `DOCLING_MAX_SYNC_WAIT`

Integraciones opcionales:
- Contrato Keycloak: `DOCLING_KEYCLOAK_*`, `DOCLING_AUTH_MODE`, `DOCLING_TRAEFIK_MIDDLEWARES`
- Hooks observabilidad: `DOCLING_OBSERVABILITY_*`, `DOCLING_SERVE_OTEL_*`, `DOCLING_OTEL_EXPORTER_OTLP_ENDPOINT`

Genera secretos con `make docling-bootstrap`.

<a id="ports"></a>
## Puertos, redes, volumenes

- Puertos publicos: ninguno (Traefik expone la API/UI)
- Redes:
  - `proxy` (solo app Docling)
  - `docling-internal` (trafico app/cache)
- Volumenes:
  - `docling-artifacts`
  - `docling-scratch`
  - `docling-model-cache`
  - `docling-redis-data`

<a id="security"></a>
## Notas de seguridad

- Docling y Redis no publican puertos al host por defecto.
- API/UI se exponen solo por Traefik con HTTPS.
- Redis queda aislado en red interna.
- La compatibilidad TLS hereda `TLS_CERT_RESOLVER` (Mode A/B/C, incluyendo Step-CA).
- El preflight es profile-gated y solo aplica checks de Docling cuando `docling` esta activo.

<a id="troubleshooting"></a>
## Troubleshooting

- Si falla preflight por secretos, ejecuta:
  - `make docling-bootstrap`
- Si hay reinicios, revisa health/logs:
  - `make docling-logs`
- Si habilitas Keycloak, completa `DOCLING_KEYCLOAK_*`.

<a id="related"></a>
## Paginas relacionadas

- [Root README](../../README.es.md)
- [Traefik](../traefik/README.es.md)
- [Observability](../observability/README.es.md)
