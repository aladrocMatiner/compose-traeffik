# Mode C: Smallstep step-ca (Internal ACME)

## Purpose / When to Use

Use Mode C when you want an internal CA for issuing certificates via ACME. Traefik obtains certificates from step-ca.

## Prerequisites

- Docker and Docker Compose
- `make`
- A configured `.env` file

## Steps

1. **Copy the example environment file (if needed):**
   ```bash
   cp .env.example .env
   ```

2. **Set required values in `.env`:**
   - `DEV_DOMAIN`
   - `STEP_CA_NAME`
   - `STEP_CA_ADMIN_PROVISIONER_PASSWORD`
   - `STEP_CA_PASSWORD`
   - `TLS_CERT_RESOLVER=stepca-resolver`

3. **Start and bootstrap step-ca:**
   ```bash
   make stepca-bootstrap
   ```

4. **Ensure hostnames resolve locally:**
   ```bash
   sudo make hosts-apply
   ```

5. **Start the stack (if not already running):**
   ```bash
   COMPOSE_PROFILES=stepca make up
   ```

6. **Verify routing:**
   ```bash
   make test
   ```

## Expected Result

- step-ca is running and bootstrapped.
- Traefik obtains certificates from step-ca.
- `whoami.$DEV_DOMAIN` returns a successful HTTPS response.

## Verification Commands

```bash
curl -vk "https://whoami.$DEV_DOMAIN/"
```

## Common Pitfalls

- **ACME directory URL mismatch:**
  - Cause: step-ca URL does not match your `DEV_DOMAIN` in Traefik config.
  - Fix: Ensure `TLS_CERT_RESOLVER=stepca-resolver` and hostnames resolve to the stack.

- **step-ca bootstrap fails:**
  - Cause: Missing or incorrect `STEP_CA_*` passwords.
  - Fix: Set `STEP_CA_ADMIN_PROVISIONER_PASSWORD` and `STEP_CA_PASSWORD` in `.env`.

## Links to Related Docs

- [Documentation Index](../README.md)
- [Repo Facts](../90-facts.md)
- [How-to: Trust Step-CA on Ubuntu 24.04](../06-howto/stepca-trust-ubuntu.md)
- [Glossary](../99-glossary.md)
