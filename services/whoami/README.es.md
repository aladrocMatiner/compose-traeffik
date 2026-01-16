[English](README.md) | [Svenska](README.sv.md) | [Espanol](README.es.md)

# Whoami service

<a id="overview"></a>
## Resumen

Whoami es un servicio demo usado para pruebas de routing y TLS.

<a id="location"></a>
## Donde vive

- `services/whoami/compose.yml`

<a id="run"></a>
## Como corre

```bash
./scripts/compose.sh up -d whoami
```

<a id="configuration"></a>
## Configuracion

Variables relevantes en `.env.example`:
- `DEV_DOMAIN`
- `TLS_CERT_RESOLVER`

<a id="ports"></a>
## Puertos, redes, volumenes

- Puertos: puerto de contenedor `80` (no publicado en host)
- Red: `proxy` (`traefik-proxy`)
- Volumenes: ninguno

<a id="security"></a>
## Notas de seguridad

- El servicio se expone solo via reglas de Traefik.

<a id="troubleshooting"></a>
## Troubleshooting

- Verifica que Traefik este corriendo: `make ps` y `make logs`.
- Confirma que `DEV_DOMAIN` existe en hosts/DNS.

<a id="related"></a>
## Paginas relacionadas

- [Root README](../../README.es.md)
- [Traefik](../traefik/README.es.md)
