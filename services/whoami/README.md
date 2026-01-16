# Whoami demo service

This directory contains the docker compose fragment that defines the `whoami` demo container used for HTTP/TLS smoke tests.

- `compose.yml` wires the service into the layered compose workflow and exposes it through Traefik labels.
- No additional configuration files are needed; the service is purely defined by its labels and the Traefik router setup.

**Run the service**
```bash
docker compose \
  -f compose/base.yml \
  -f services/whoami/compose.yml \
  --env-file .env up whoami
```
