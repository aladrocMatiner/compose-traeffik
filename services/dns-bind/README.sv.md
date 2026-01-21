[English](README.md) | [Svenska](README.sv.md) | [Espanol](README.es.md)

# DNS service (BIND)

<a id="overview"></a>
## Oversikt

BIND ar en valfri DNS-profil som serverar lokala zoner for projektets domaner. Provisioneringsscriptet skapar zone-filen fran stackens inputs.

<a id="location"></a>
## Var finns det

- `services/dns-bind/zones/`

<a id="run"></a>
## Hur den kor

Provisionera zone-filen:
```bash
make bind-provision
```

Dry-run av zone-filen:
```bash
make bind-provision-dry
```

<a id="configuration"></a>
## Konfiguration

Relevanta env vars i `.env.example`:
- `BASE_DOMAIN`
- `LOOPBACK_X`
- `ENDPOINTS`

<a id="zones"></a>
## Zone layout

Zone-filen skrivs till:
- `services/dns-bind/zones/db.${BASE_DOMAIN}`

Filen innehaller A-poster for varje endpoint samt `bind.${BASE_DOMAIN}` pa `127.0.${LOOPBACK_X}.254`.

<a id="verification"></a>
## Verifiering

```bash
ls -l services/dns-bind/zones/db.${BASE_DOMAIN}
cat services/dns-bind/zones/db.${BASE_DOMAIN}
```

<a id="related"></a>
## Relaterade sidor

- [Root README](../../README.sv.md)
- [Traefik](../traefik/README.sv.md)
