# Mode C: Step-CA ACME

## Overview

Mode C uses Smallstep step-ca as an internal ACME server. Traefik requests certificates from step-ca when `TLS_CERT_RESOLVER=stepca-resolver` is set.

## Prerequisites

- Docker and Docker Compose
- `make`
- A configured `.env` file

## Steps

1. **Create your env file**
   ```bash
   cp .env.example .env
   ```

2. **Set required values in `.env`**
   - `DEV_DOMAIN`
   - Shared CA values: `CA_NAME`, `CA_DNS`, `CA_IPS` (or legacy `STEP_CA_NAME`, `STEP_CA_DNS`)
   - `STEP_CA_ADMIN_PROVISIONER_PASSWORD`
   - `STEP_CA_PASSWORD`
   - `STEP_CA_CA_SERVER`
   - `TLS_CERT_RESOLVER=stepca-resolver`

3. **Start step-ca and bootstrap**
   ```bash
   make stepca-up
   make stepca-bootstrap
   ```

4. **Trust the step-ca root certificate (Ubuntu 24.04)**
   ```bash
   sudo make stepca-trust-install
   ```

5. **Ensure hostnames resolve locally**
   ```bash
   sudo make hosts-apply
   ```

6. **Start the stack**
   ```bash
   COMPOSE_PROFILES=stepca make up
   ```

7. **Run smoke tests**
   ```bash
   make test
   ```

## Expected result

- step-ca is running and bootstrapped.
- Traefik obtains certificates from step-ca.
- `https://whoami.${DEV_DOMAIN}` responds over HTTPS with the step-ca chain.

## Verification

```bash
curl -vk "https://whoami.${DEV_DOMAIN}/"
```

## Renewal / rotation

- step-ca issues short-lived certs automatically via ACME.
- Re-run `make stepca-bootstrap` only if you reinitialize the CA data.

## Rollback to Mode A

- Set `TLS_CERT_RESOLVER=` in `.env`.
- Stop step-ca (`make stepca-down`).
- Run `make certs-local` and `make up`.

## Common pitfalls

- **ACME directory URL mismatch**: ensure `STEP_CA_CA_SERVER` matches your step-ca URL (default uses `https://step-ca.${DEV_DOMAIN}:9000/acme/acme/directory`).
- **Bootstrap fails**: ensure `STEP_CA_ADMIN_PROVISIONER_PASSWORD` and `STEP_CA_PASSWORD` are set in `.env`.
- **Untrusted certificates**: install the step-ca root with `make stepca-trust-install`.

## Troubleshooting

- Use `make logs` to inspect `step-ca` and `traefik` output.
- Confirm the `stepca` profile is active and the container is running (`make ps`).
- Re-run `make stepca-trust-verify` to confirm trust.

## Related

- [Root README](../README.md)
- [Mode A: Self-signed](tls-mode-a-selfsigned.md)
- [Mode B: Let's Encrypt + Certbot](tls-mode-b-letsencrypt-certbot.md)
