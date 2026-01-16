# Traefik service

This directory houses the asset bundle for the primary `traefik` reverse proxy.

- `compose.yml` defines the Traefik container in the layered compose workflow.
- `traefik.yml` and `dynamic/` hold the static and dynamic configuration files.
- `dynamic-rendered/` stores the rendered configuration produced by `scripts/traefik-render-dynamic.sh`.
- `auth/` keeps BasicAuth htpasswd files (e.g., `dns-ui.htpasswd.example`).
- TLS assets such as local CA/leaf certificates live under `shared/certs/`.

**Run the service**
```bash
docker compose \
  -f compose/base.yml \
  -f services/traefik/compose.yml \
  --env-file .env up traefik
```

**Useful scripts**
- `scripts/traefik-render-dynamic.sh` (renders `dynamic/`).
- `scripts/certs-selfsigned-generate.sh` (populates `shared/certs/`).
