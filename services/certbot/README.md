[English](README.md) | [Svenska](README.sv.md) | [Espanol](README.es.md)

# Certbot service

<a id="overview"></a>
## Overview

Certbot is an optional profile used to issue and renew Let's Encrypt certificates.

<a id="location"></a>
## Where it lives

- `services/certbot/compose.yml`
- `services/certbot/conf/`
- `services/certbot/www/`

<a id="run"></a>
## How it runs

Start the profile container:
```bash
./scripts/compose.sh --profile le up -d certbot
```

Issue or renew certificates:
```bash
make certbot-issue
make certbot-renew
```

<a id="configuration"></a>
## Configuration

Relevant env vars in `.env.example`:
- `DEV_DOMAIN`
- `ACME_EMAIL`
- `LETSENCRYPT_STAGING`

<a id="ports"></a>
## Ports, networks, volumes

- Ports: the certbot scripts bind `80:80` and `443:443` during issuance/renewal
- Networks: default compose network
- Volumes:
  - `services/certbot/conf` -> `/etc/letsencrypt`
  - `services/certbot/www` -> `/var/www/certbot`

<a id="security"></a>
## Security notes

- The `le` profile is optional and should be enabled only when needed.

<a id="troubleshooting"></a>
## Troubleshooting

- Ensure `ACME_EMAIL` is set in `.env`.
- If issuance fails, check `make logs certbot`.

<a id="related"></a>
## Related pages

- [Root README](../../README.md)
- [Traefik](../traefik/README.md)
