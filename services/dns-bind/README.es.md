[English](README.md) | [Svenska](README.sv.md) | [Espanol](README.es.md)

# DNS service (BIND)

<a id="overview"></a>
## Resumen

BIND es un perfil DNS opcional que sirve zonas locales para los dominios del proyecto.

<a id="location"></a>
## Donde vive

- `services/dns-bind/compose.yml`
- `services/dns-bind/config/`
- `services/dns-bind/zones/`

<a id="run"></a>
## Como corre

Provisiona el zone file:
```bash
make bind-provision
```

Inicia el servicio:
```bash
make bind-up
```

Ver logs:
```bash
make bind-logs
```

Detiene el servicio:
```bash
make bind-down
```

<a id="configuration"></a>
## Configuracion

Variables relevantes en `.env.example`:
- `BASE_DOMAIN`
- `LOOPBACK_X`
- `ENDPOINTS`
- `BIND_BIND_ADDRESS`

<a id="ports"></a>
## Puertos, redes, volumenes

- Puertos: `53/udp`, `53/tcp` (ligados a `BIND_BIND_ADDRESS`)
- Red: `proxy` (`traefik-proxy`)
- Volumenes: `services/dns-bind/config` y `services/dns-bind/zones`

<a id="security"></a>
## Notas de seguridad

- No habilitar `dns` y `bind` a la vez (conflicto en el puerto 53).

<a id="troubleshooting"></a>
## Troubleshooting

- Puerto 53 en uso: detiene el servicio en conflicto o cambia `BIND_BIND_ADDRESS`.
- Falta zone file: ejecuta `make bind-provision` antes de iniciar.

<a id="related"></a>
## Paginas relacionadas

- [Root README](../../README.es.md)
- [Traefik](../traefik/README.es.md)
