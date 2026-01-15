# DNS Service (Technitium) - Bind + Split-DNS on Ubuntu 24.04

## Purpose / When to Use

Use this guide to enable the DNS service profile, expose its UI securely via Traefik, provision DNS records for project endpoints, and configure Ubuntu 24.04 to resolve `*.${BASE_DOMAIN}` via the local DNS server.

## Prerequisites

- Docker and Docker Compose
- `make`
- Ubuntu 24.04 for split-DNS configuration
- A configured `.env` file

## Steps

1. **Copy the example environment file (if needed):**
   ```bash
   cp .env.example .env
   ```

2. **Set project domain variables in `.env`:**
   - `PROJECT_NAME` (used for the default domain convention)
   - `BASE_DOMAIN=${PROJECT_NAME}.aladroc.io`
   - `DEV_DOMAIN` should match `BASE_DOMAIN` unless you intentionally separate them
   - `LOOPBACK_X` (loopback X octet)
   - `ENDPOINTS` (comma-separated list of endpoints, optional)

3. **Create DNS UI BasicAuth credentials:**
   ```bash
   cp traefik/auth/dns-ui.htpasswd.example traefik/auth/dns-ui.htpasswd
   # Replace with your own credentials:
   # htpasswd -nbB admin 'change-me' > traefik/auth/dns-ui.htpasswd
   ```

4. **Start the DNS service (dns profile):**
   ```bash
   make dns-up
   ```

5. **Provision DNS records:**
   ```bash
   make dns-provision
   ```

6. **Configure Ubuntu 24.04 split-DNS (requires sudo):**
   ```bash
   sudo make dns-config-apply
   ```

## Expected Result

- The DNS service runs with port 53 bound to `DNS_BIND_ADDRESS` (default: `127.0.0.1`).
- The DNS UI is available at `https://dns.$BASE_DOMAIN/` through Traefik.
- A records exist for each endpoint, plus `dns.$BASE_DOMAIN` at `127.0.$LOOPBACK_X.254`.
- Ubuntu resolves `*.${BASE_DOMAIN}` using the local DNS server.

## Verification Commands

```bash
make dns-status
resolvectl status

dig @127.0.0.1 dns.$BASE_DOMAIN
getent hosts whoami.$BASE_DOMAIN

curl -vk "https://dns.$BASE_DOMAIN/"
```

## Common Pitfalls

- **DNS port 53 already in use:**
  - Symptom: DNS service fails to start or port binding errors.
  - Fix: Stop the conflicting service or change `DNS_BIND_ADDRESS` to a different IP.

- **UI not reachable:**
  - Symptom: `https://dns.$BASE_DOMAIN/` does not load.
  - Diagnose: Check Traefik logs and verify the `dns` profile is running.
  - Fix: Run `make dns-up` and confirm Traefik is running.

- **Authentication failures:**
  - Symptom: Browser prompts repeatedly or returns 401.
  - Fix: Regenerate `traefik/auth/dns-ui.htpasswd` with valid credentials.

- **Split-DNS not applied:**
  - Symptom: `getent hosts` returns no results for `*.${BASE_DOMAIN}`.
  - Diagnose: Run `resolvectl status` and confirm the `~${BASE_DOMAIN}` routing is present.
  - Fix: Re-run `sudo make dns-config-apply`.

## Security Notes

- The DNS UI is exposed only via Traefik HTTPS and protected by BasicAuth.
- The DNS UI port is not published directly on the host.
- To enable an IP allowlist, add `dns-ui-allowlist@docker` to `DNS_UI_MIDDLEWARES` and set `DNS_UI_ALLOWLIST_SOURCE_RANGES`.

## Links to Related Docs

- [Documentation Index](../README.md)
- [Repo Facts](../90-facts.md)
- [Style Guide](../99-style-guide.md)
- [Glossary](../99-glossary.md)
