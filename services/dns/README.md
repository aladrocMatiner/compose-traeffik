# Technitium DNS service data

This directory stores persistent data for the Technitium DNS service that runs under the `dns` profile.

- `compose.yml` defines the DNS container and Traefik labels for `dns.<BASE_DOMAIN>`.
- `data/` is mounted into `/etc/dns` inside the container and should never contain production secrets.

**Run the DNS profile**
```bash
docker compose \
  -f compose/base.yml \
  -f services/dns/compose.yml \
  --env-file .env --profile dns up dns
```
