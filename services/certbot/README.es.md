[English](README.md) | [Svenska](README.sv.md) | [Espanol](README.es.md)

# Certbot service

<a id="overview"></a>
## Resumen

Certbot es un perfil opcional para emitir y renovar certificados Let's Encrypt.

<a id="location"></a>
## Donde vive

- `services/certbot/compose.yml`
- `services/certbot/conf/`
- `services/certbot/www/`

<a id="run"></a>
## Como corre

Inicia los contenedores del perfil (certbot + certbot-web):
```bash
./scripts/compose.sh --profile le up -d certbot certbot-web
```

Emite o renueva certificados:
```bash
make certs-le-issue
make certs-le-renew
```

<a id="configuration"></a>
## Configuracion

Variables relevantes en `.env.example`:
- `DEV_DOMAIN`
- `ACME_EMAIL`
- `LETSENCRYPT_STAGING`

<a id="ports"></a>
## Puertos, redes, volumenes

- Puertos: no hay bind directo; Traefik enruta `/.well-known/acme-challenge/` a `certbot-web` y Certbot usa `--webroot`
- Red: red por defecto de compose
- Volumenes:
  - `services/certbot/conf` -> `/etc/letsencrypt`
  - `services/certbot/www` -> `/var/www/certbot`

<a id="security"></a>
## Notas de seguridad

- El perfil `le` es opcional y se debe activar solo cuando sea necesario.

<a id="troubleshooting"></a>
## Troubleshooting

- Verifica que `ACME_EMAIL` este en `.env`.
- Si falla la emision, revisa `make logs certbot`.

<a id="related"></a>
## Paginas relacionadas

- [Root README](../../README.es.md)
- [Traefik](../traefik/README.es.md)
