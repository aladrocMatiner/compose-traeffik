[English](README.md) | [Svenska](README.sv.md) | [Espanol](README.es.md)

# Traefik service

<a id="overview"></a>
## Resumen

Traefik es el reverse proxy y el nucleo de routing de esta stack. Maneja HTTP/HTTPS y carga configuracion dinamica desde `services/traefik/dynamic-rendered`.

<a id="location"></a>
## Donde vive

- `services/traefik/compose.yml`
- `services/traefik/traefik.yml`
- `services/traefik/dynamic/`
- `services/traefik/dynamic-rendered/`
- `services/traefik/auth/`

<a id="run"></a>
## Como corre

```bash
./scripts/compose.sh up -d traefik
```

La configuracion dinamica se renderiza con `scripts/traefik-render-dynamic.sh`, ejecutado por `scripts/up.sh`.

<a id="configuration"></a>
## Configuracion

Variables relevantes en `.env.example`:
- `DEV_DOMAIN`
- `TRAEFIK_IMAGE`
- `TLS_CERT_RESOLVER`

<a id="ports"></a>
## Puertos, redes, volumenes

- Puertos: `80`, `443`, `8080`
- Red: `proxy` (`traefik-proxy`)
- Volumenes:
  - `/var/run/docker.sock` (read-only)
  - `services/traefik/traefik.yml`
  - `services/traefik/dynamic-rendered`
  - `certs-data` volume
  - `shared/certs/local`

<a id="security"></a>
## Notas de seguridad

- Dashboard no es inseguro (`api.insecure=false`).
- La exposicion requiere routing y middleware explicitos.

<a id="troubleshooting"></a>
## Troubleshooting

- Usa `make logs` y revisa logs de `traefik`.
- Si falla el routing, ejecuta `make up` para renderizar de nuevo el config dinamico.

<a id="related"></a>
## Paginas relacionadas

- [Root README](../../README.es.md)
- [Whoami](../whoami/README.es.md)
