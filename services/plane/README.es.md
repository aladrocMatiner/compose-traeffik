[English](README.md) | [Svenska](README.sv.md) | [Espanol](README.es.md)

# Plane service

<a id="overview"></a>
## Resumen

Plane es un modulo opcional de gestion de proyectos expuesto detras de Traefik. Este modulo ejecuta servicios de Plane y dependencias internas PostgreSQL, Redis (Valkey), RabbitMQ y MinIO.

<a id="location"></a>
## Donde vive

- `services/plane/compose.yml`

<a id="run"></a>
## Como corre

```bash
make plane-bootstrap
make plane-up
make plane-status
```

URL (via Traefik): `https://plane.${DEV_DOMAIN}`

<a id="configuration"></a>
## Configuracion

Variables relevantes en `.env.example`:
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

Integraciones opcionales:
- Contrato Keycloak/OIDC: `PLANE_OIDC_*`, `PLANE_KEYCLOAK_*`
- Hooks de observabilidad: `PLANE_OBSERVABILITY_*`, `PLANE_OTEL_*`

Genera secretos con `make plane-bootstrap`.

<a id="ports"></a>
## Puertos, redes, volumenes

- Puertos publicos: ninguno (Traefik expone la UI)
- Redes:
  - `proxy` (solo servicio web de Plane)
  - `plane-internal` (trafico app/dependencias)
- Volumenes:
  - `plane-pgdata`
  - `plane-redisdata`
  - `plane-rabbitmq-data`
  - `plane-uploads`
  - `plane-logs-api`
  - `plane-logs-worker`
  - `plane-logs-beat-worker`
  - `plane-logs-migrator`

<a id="security"></a>
## Notas de seguridad

- Las dependencias de Plane no publican puertos al host por defecto.
- La UI se expone solo por Traefik con HTTPS.
- DB/cache/broker/object-store quedan aislados en red interna.
- La compatibilidad de TLS hereda `TLS_CERT_RESOLVER` (Mode A/B/C, incluyendo Step-CA).
- El preflight es profile-gated y solo aplica checks de Plane cuando `plane` esta activo.

<a id="troubleshooting"></a>
## Troubleshooting

- Si falla preflight, genera secretos faltantes:
  - `make plane-bootstrap`
- Si hay reinicios, revisa la cadena de readiness:
  - `make plane-logs`
- Si habilitas OIDC, completa todo el contrato `PLANE_OIDC_*`.
- Si usas un profile local de Keycloak en el futuro, usa `PLANE_KEYCLOAK_MODE=local` con `PLANE_KEYCLOAK_INTERNAL_URL`.

<a id="related"></a>
## Paginas relacionadas

- [Root README](../../README.es.md)
- [Traefik](../traefik/README.es.md)
- [Observability](../observability/README.es.md)
