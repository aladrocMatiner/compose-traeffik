[English](README.md) | [Svenska](README.sv.md) | [Espanol](README.es.md)

# CTFd service

<a id="overview"></a>
## Resumen

CTFd es un modulo opcional de plataforma CTF expuesto detras de Traefik. Este modulo ejecuta `ctfd` con dependencias internas MariaDB y Redis.

<a id="location"></a>
## Donde vive

- `services/ctfd/compose.yml`

<a id="run"></a>
## Como corre

```bash
make ctfd-bootstrap
make ctfd-up
make ctfd-status
```

URL (via Traefik): `https://ctfd.${DEV_DOMAIN}`

<a id="configuration"></a>
## Configuracion

Variables relevantes en `.env.example`:
- `CTFD_HOSTNAME`
- `CTFD_IMAGE`
- `CTFD_DB_IMAGE`
- `CTFD_REDIS_IMAGE`
- `CTFD_SECRET_KEY`
- `CTFD_DB_NAME`
- `CTFD_DB_USER`
- `CTFD_DB_PASSWORD`
- `CTFD_DB_ROOT_PASSWORD`
- `CTFD_WORKERS`

Puedes generar/persistir secretos con `make ctfd-bootstrap`.

<a id="ports"></a>
## Puertos, redes, volumenes

- Puertos publicos: ninguno (Traefik expone la UI)
- Redes:
  - `proxy` (solo app CTFd)
  - `ctfd-internal` (trafico app/db/cache)
- Volumenes:
  - `ctfd-db-data`
  - `ctfd-redis-data`
  - `ctfd-uploads`
  - `ctfd-logs`

<a id="security"></a>
## Notas de seguridad

- CTFd, MariaDB y Redis no publican puertos al host por defecto.
- La UI se expone solo por Traefik con HTTPS.
- DB/cache quedan aislados en red interna.
- El preflight exige secretos CTFd cuando el profile `ctfd` esta activo.

<a id="troubleshooting"></a>
## Troubleshooting

- El admin inicial se crea desde la UI de CTFd en el primer arranque.
- Si hay reinicios, revisa readiness de DB/cache:
  - `make ctfd-logs`
- Si falla preflight, genera secretos:
  - `make ctfd-bootstrap`

<a id="related"></a>
## Paginas relacionadas

- [Root README](../../README.es.md)
- [Traefik](../traefik/README.es.md)
- [Observability](../observability/README.es.md)
