# Certbot service

This directory hosts the compose fragment and bind mounts for the optional Let's Encrypt profile.

- `compose.yml` configures the `certbot` container held alive for manual issuance/renewal.
- `conf/` is mounted at `/etc/letsencrypt` and should hold your certbot configuration.
- `www/` is mounted at `/var/www/certbot` for ACME HTTP challenges.

**Execute Certbot**
```bash
docker compose \
  -f compose/base.yml \
  -f services/certbot/compose.yml \
  --env-file .env --profile le up certbot
```
