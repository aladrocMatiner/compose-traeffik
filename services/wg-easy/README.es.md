[English](README.md) | [Svenska](README.sv.md) | [Espanol](README.es.md)

# Servicio wg-easy (WireGuard)

<a id="overview"></a>
## Overview

`wg-easy` proporciona un servidor WireGuard con UI web para gestionar peers y exportar configuraciones de cliente.
En este proyecto, la UI se expone detras de Traefik por HTTPS, mientras el tunel WireGuard usa un puerto UDP del host.

<a id="location"></a>
## Where it lives

- `services/wg-easy/compose.yml`
- `services/wg-easy/data/` (estado runtime; ignorado por git)
- `scripts/wg-bootstrap.sh` (bootstrap de variables admin en `.env`)

<a id="run"></a>
## How it runs

Primero bootstrap de variables admin en `.env`:
```bash
make wg-bootstrap
```

Inicia el servicio:
```bash
make wg-up
```

Inspecciona estado/logs:
```bash
make wg-status
make wg-logs
```

Deten el servicio:
```bash
make wg-down
```

<a id="configuration"></a>
## Configuration

Variables relevantes en `.env.example`:
- `WG_EASY_IMAGE`
- `WG_UI_HOSTNAME`
- `WG_UI_MIDDLEWARES`
- `WG_INSECURE` (debe permanecer en `false` en esta integracion)
- `WG_BIND_ADDRESS`
- `WG_ALLOW_NONLOCAL_BIND`
- `WG_SERVER_PORT`
- `WG_SERVER_ENDPOINT`
- `WG_INIT_ENABLED`
- `WG_INIT_USERNAME`
- `WG_INIT_PASSWORD` (lo genera `make wg-bootstrap`)
- `TLS_CERT_RESOLVER`
- `DEV_DOMAIN`

Notas de bootstrap/rotacion:
- `make wg-bootstrap` rellena `WG_INIT_*` vacios en `.env` y no sobreescribe valores existentes por defecto.
- Para rotar valores soportados de bootstrap, usa `WG_BOOTSTRAP_ARGS=--force make wg-bootstrap`.

<a id="ports"></a>
## Ports, networks, volumes

- Ports:
  - UDP `WG_BIND_ADDRESS:WG_SERVER_PORT -> 51820/udp` (tunel WireGuard)
  - El puerto TCP de la UI **no** se publica en el host (se sirve via Traefik)
- Networks:
  - `proxy`
- Volumes:
  - `services/wg-easy/data` -> `/etc/wireguard`

<a id="security"></a>
## Security notes

- La UI admin se enruta por Traefik HTTPS y `WG_INSECURE=true` es bloqueado por preflight.
- La exposicion UDP fuera de loopback requiere confirmacion explicita: `WG_ALLOW_NONLOCAL_BIND=true`.
- El contenedor usa capabilities/devices explicitos y no usa `privileged: true` por defecto.
- El estado runtime en `services/wg-easy/data/` puede contener material sensible y esta ignorado por git.

Prerequisitos del host (Linux tipico):
- `/dev/net/tun` disponible
- Docker con soporte para capabilities/devices requeridos
- Soporte de kernel para WireGuard / forwarding segun el host

<a id="troubleshooting"></a>
## Troubleshooting

- **La UI no responde en `https://wg.<DEV_DOMAIN>`**
  - Revisa `make wg-status`, `make logs` y logs de Traefik.
  - Verifica que `WG_UI_HOSTNAME` y `DEV_DOMAIN` coinciden con tu hosts/DNS.
  - Agrega `wg` a `ENDPOINTS` y reejecuta `make hosts-apply` si usas hosts mapping.

- **Preflight bloquea el arranque de WireGuard**
  - Revisa `WG_BIND_ADDRESS`, `WG_ALLOW_NONLOCAL_BIND`, `WG_SERVER_PORT`, `WG_SERVER_ENDPOINT` y `WG_INSECURE` en `.env`.

- **El contenedor falla por TUN/capabilities**
  - Confirma que `/dev/net/tun` existe y Docker puede montarlo.
  - Revisa soporte del host/kernel y restricciones del runtime.

<a id="related"></a>
## Related pages

- [Root README](../../README.es.md)
- [Traefik](../traefik/README.es.md)
- `tests/README.md`
- `scripts/README.md`
