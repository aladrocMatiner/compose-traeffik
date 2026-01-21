[English](README.md) | [Svenska](README.sv.md) | [Espanol](README.es.md)

# DNS service (BIND)

<a id="overview"></a>
## Overview

BIND is an optional DNS profile that serves local zones for the project domains. The provisioning script generates the zone file from the stack inputs.

<a id="location"></a>
## Where it lives

- `services/dns-bind/zones/`

<a id="run"></a>
## How it runs

Provision the zone file:
```bash
make bind-provision
```

Dry-run the zone file:
```bash
make bind-provision-dry
```

<a id="configuration"></a>
## Configuration

Relevant env vars in `.env.example`:
- `BASE_DOMAIN`
- `LOOPBACK_X`
- `ENDPOINTS`

<a id="zones"></a>
## Zone layout

The zone file is written to:
- `services/dns-bind/zones/db.${BASE_DOMAIN}`

The file includes A records for each endpoint plus `bind.${BASE_DOMAIN}` at `127.0.${LOOPBACK_X}.254`.

<a id="verification"></a>
## Verification

```bash
ls -l services/dns-bind/zones/db.${BASE_DOMAIN}
cat services/dns-bind/zones/db.${BASE_DOMAIN}
```

<a id="related"></a>
## Related pages

- [Root README](../../README.md)
- [Traefik](../traefik/README.md)
