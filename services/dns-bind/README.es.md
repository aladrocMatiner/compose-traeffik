[English](README.md) | [Svenska](README.sv.md) | [Espanol](README.es.md)

# DNS service (BIND)

<a id="overview"></a>
## Resumen

BIND es un perfil DNS opcional que sirve zonas locales para los dominios del proyecto. El script de provision genera el zone file desde los inputs del stack.

<a id="location"></a>
## Donde vive

- `services/dns-bind/zones/`

<a id="run"></a>
## Como corre

Provisiona el zone file:
```bash
make bind-provision
```

Dry-run del zone file:
```bash
make bind-provision-dry
```

<a id="configuration"></a>
## Configuracion

Variables relevantes en `.env.example`:
- `BASE_DOMAIN`
- `LOOPBACK_X`
- `ENDPOINTS`

<a id="zones"></a>
## Zone layout

El zone file se escribe en:
- `services/dns-bind/zones/db.${BASE_DOMAIN}`

El archivo incluye registros A para cada endpoint y `bind.${BASE_DOMAIN}` en `127.0.${LOOPBACK_X}.254`.

<a id="verification"></a>
## Verificacion

```bash
ls -l services/dns-bind/zones/db.${BASE_DOMAIN}
cat services/dns-bind/zones/db.${BASE_DOMAIN}
```

<a id="related"></a>
## Paginas relacionadas

- [Root README](../../README.es.md)
- [Traefik](../traefik/README.es.md)
