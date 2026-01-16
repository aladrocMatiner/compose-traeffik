# Mode B: Let's Encrypt (Certbot)

## Overview

Mode B uses Certbot to issue publicly trusted certificates from Let's Encrypt. The certbot service runs under the `le` profile and writes certs to `services/certbot/conf`.

## Prerequisites

- Docker and Docker Compose
- `make`
- A configured `.env` file
- A public domain that resolves to this host
- Ports 80 and 443 reachable from the internet

## Steps

1. **Create your env file**
   ```bash
   cp .env.example .env
   ```

2. **Set required values in `.env`**
   - `DEV_DOMAIN`
   - `ACME_EMAIL`
   - `LETSENCRYPT_STAGING` (set `true` for staging)
   - `TLS_CERT_RESOLVER=le-resolver`

3. **Start the stack with the `le` profile**
   ```bash
   COMPOSE_PROFILES=le make up
   ```

4. **Issue certificates with Certbot**
   ```bash
   make certs-le-issue
   ```

5. **Verify routing**
   ```bash
   make test
   ```

## Expected result

- Certbot issues certificates for `${DEV_DOMAIN}` and subdomains defined in `scripts/certbot-issue.sh`.
- Certificates are stored under `services/certbot/conf/live/`.
- Traefik serves HTTPS with Let's Encrypt when `TLS_CERT_RESOLVER=le-resolver` is set.

## Verification

```bash
curl -vk "https://whoami.${DEV_DOMAIN}/"
```

## Renewal / rotation

- Run `make certs-le-renew` to renew certificates.
- Re-run `make certs-le-issue` if you add new domains in the script.

## Rollback to Mode A

- Set `TLS_CERT_RESOLVER=` in `.env`.
- Re-run `make certs-local` and `make up`.

## Common pitfalls

- **Ports 80/443 are already in use**: stop the stack before running `make certs-le-issue`, then start it again.
- **Domain does not resolve publicly**: Let's Encrypt validation will fail.
- **Staging certificates are not trusted**: set `LETSENCRYPT_STAGING=false` for production issuance.

## Troubleshooting

- Check Certbot output in the terminal for validation errors.
- Run `make logs certbot` to inspect certbot container logs.
- Verify DNS points to this host and port 80 is reachable.

## Related

- [Root README](../README.md)
- [Mode A: Self-signed](tls-mode-a-selfsigned.md)
- [Mode C: Step-CA ACME](tls-mode-c-stepca-acme.md)
