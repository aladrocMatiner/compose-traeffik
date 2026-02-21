# DNS Service (BIND)

## Purpose / When to Use

Use this guide to enable the BIND DNS service profile, generate a local zone file for project endpoints, and run a local DNS server bound to your chosen address.

## Prerequisites

- Docker and Docker Compose
- `make`
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
   - `BIND_BIND_ADDRESS` (set to your target interface IP)
   - `BIND_ALLOW_NONLOCAL_BIND=true` when using non-loopback addresses

3. **Generate the zone file:**
   ```bash
   make bind-provision
   ```
   Zone file location:
   - `services/dns-bind/zones/db.${BASE_DOMAIN}`
   - Example: `services/dns-bind/zones/db.aladroc.io`
   - Manual custom records must be added to that `db.<domain>` file.

4. **Start the BIND service (bind profile):**
   ```bash
   make bind-up
   ```

5. **Check status and restart when needed:**
   ```bash
   make bind-status
   make bind-restart
   ```

## Expected Result

- The BIND service runs with port 53 bound to `BIND_BIND_ADDRESS`.
- A zone file exists under `services/dns-bind/zones/` for `${BASE_DOMAIN}`.
- A records exist for each endpoint plus `bind.${BASE_DOMAIN}` at `127.0.${LOOPBACK_X}.254`.

## Verification Commands

```bash
make bind-status
make bind-logs

dig @127.0.0.1 whoami.${BASE_DOMAIN}
getent hosts whoami.${BASE_DOMAIN}
```

## Common Pitfalls

- **DNS port 53 already in use:**
  - Symptom: BIND fails to start or port binding errors.
  - Fix: Stop the conflicting service or change `BIND_BIND_ADDRESS` to a different IP.

- **Missing zone file:**
  - Symptom: BIND starts but queries for `${BASE_DOMAIN}` fail.
  - Fix: Run `make bind-provision` before starting the service.

## Security Notes

- BIND listens on `BIND_BIND_ADDRESS`.
- Recursion is disabled by default in the provided `named.conf.template`.
- Zone transfer (`AXFR`) is denied by default.
- CHAOS metadata (`version.bind`, `hostname.bind`, `id.server`) is minimized.
- Non-loopback DNS exposure requires `BIND_ALLOW_NONLOCAL_BIND=true`.

## Security Verification

Use these checks after DNS changes:

```bash
make test
./tests/smoke/test_bind_guardrails.sh
./tests/smoke/test_bind_security_runtime.sh
```

Manual checks:

```bash
# Recursion should be unavailable/refused.
dig @127.0.0.1 example.com A

# AXFR should be denied.
dig @127.0.0.1 ${BASE_DOMAIN} AXFR

# Metadata should not disclose version/host identity.
dig @127.0.0.1 version.bind TXT CH
dig @127.0.0.1 hostname.bind TXT CH
dig @127.0.0.1 id.server TXT CH
```

## Rollback Checklist

If hardening changes break DNS unexpectedly:

1. Validate config and zone generation:
   ```bash
   make bind-provision
   make bind-status
   make bind-logs
   ```
2. Restart BIND lifecycle cleanly:
   ```bash
   make bind-restart
   ```
3. Confirm smoke baseline:
   ```bash
   make test
   ```
4. If non-loopback DNS exposure was temporary, revert:
   - `BIND_BIND_ADDRESS` to loopback
   - `BIND_ALLOW_NONLOCAL_BIND=false`

## Links to Related Docs

- [Documentation Index](../README.md)
- [Repo Facts](../90-facts.md)
- [Style Guide](../99-style-guide.md)
- [Glossary](../99-glossary.md)
