[English](README.md) | [Svenska](README.sv.md) | [Espanol](README.es.md)

# DNS service (Technitium)

<a id="overview"></a>
## Resumen

Technitium DNS es un perfil opcional que provee DNS para el dominio del proyecto y expone su UI via Traefik.

<a id="location"></a>
## Donde vive

- `services/dns/compose.yml`
- `services/dns/data/`

<a id="run"></a>
## Como corre

```bash
./scripts/compose.sh --profile dns up -d dns
```

Provisiona records:
```bash
make dns-provision
```

Configura Ubuntu split-DNS:
```bash
sudo make dns-config-apply
```

<a id="configuration"></a>
## Configuracion

Variables relevantes en `.env.example`:
- `BASE_DOMAIN`
- `DNS_ADMIN_PASSWORD`
- `DNS_BIND_ADDRESS`
- `DNS_UI_HOSTNAME`
- `DNS_UI_MIDDLEWARES`
- `DNS_UI_ALLOWLIST_SOURCE_RANGES`
- `LOOPBACK_X`
- `ENDPOINTS`

<a id="ports"></a>
## Puertos, redes, volumenes

- Puertos: `53/udp`, `53/tcp` (ligados a `DNS_BIND_ADDRESS`)
- Red: `proxy` (`traefik-proxy`)
- Volumen: `services/dns/data` -> `/etc/dns`

<a id="security"></a>
## Notas de seguridad

- La UI se expone solo via Traefik en `https://dns.${BASE_DOMAIN}`.
- El puerto 53 se liga a localhost por defecto.

<a id="troubleshooting"></a>
## Troubleshooting

- Confirma que el perfil `dns` este activo y `DNS_ADMIN_PASSWORD` este configurado.
- Usa `make dns-logs` y `make dns-status`.

<a id="related"></a>
## Paginas relacionadas

- [Root README](../../README.es.md)
- [Traefik](../traefik/README.es.md)
