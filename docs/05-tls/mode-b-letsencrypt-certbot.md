# Mode B: Let's Encrypt via Certbot

## Purpose / When to Use

Use Mode B when you want publicly trusted certificates from Let's Encrypt for development or staging environments. Certificates are issued by Certbot and used by Traefik.

## Prerequisites

- Docker and Docker Compose
- `make`
- A configured `.env` file
- A domain that resolves to your machine (Let's Encrypt must reach it)

## Steps

1. **Copy the example environment file (if needed):**
   ```bash
   cp .env.example .env
   ```

2. **Set required values in `.env`:**
   - `DEV_DOMAIN`
   - `ACME_EMAIL`
   - `LETSENCRYPT_STAGING` (use `true` for testing)
   - `LETSENCRYPT_CA_SERVER`

3. **Start the stack with the `le` profile:**
   ```bash
   COMPOSE_PROFILES=le make up
   ```

4. **Issue a certificate with Certbot:**
   ```bash
   make certs-le-issue
   ```

5. **Verify routing:**
   ```bash
   make test
   ```

## Expected Result

- Certbot issues a certificate for the configured domain.
- Traefik serves the certificate for HTTPS requests.
- `whoami.$DEV_DOMAIN` returns a successful HTTPS response.

## Verification Commands

```bash
curl -vk "https://whoami.$DEV_DOMAIN/"
```

## Common Pitfalls

- **Certbot issuance fails:**
  - Cause: The domain does not resolve publicly to your host or port 80 is blocked.
  - Fix: Ensure DNS and inbound ports 80/443 are reachable.

- **Certbot scripts use hardcoded domains:**
  - Cause: Current `scripts/certbot-issue.sh` and `scripts/certbot-renew.sh` hardcode domains.
  - Fix: Update those scripts to match your `DEV_DOMAIN` before issuance.

## Links to Related Docs

- [Documentation Index](../README.md)
- [Repo Facts](../90-facts.md)
- [Glossary](../99-glossary.md)
