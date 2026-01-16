# Migration: Services Layout Refactor

This repository now uses a layered compose workflow where each service lives under `services/<service>/` and a shared `compose/base.yml` defines common networks/volumes. Update any tooling or overrides that previously referenced top-level paths:

| Legacy path | New location | Notes |
|-------------|--------------|-------|
| `docker-compose.yml` | `compose/base.yml` + `services/<service>/compose.yml` | Use `docker compose -f compose/base.yml -f services/traefik/compose.yml -f services/whoami/compose.yml ...` or the helper script `./scripts/compose.sh`. |
| `traefik/` | `services/traefik/` | Static config, dynmic templates, rendered output, and auth files live here. |
| `dns/data/` | `services/dns/data/` | Technitium DNS persistent data directory. |
| `step-ca/config/` / `step-ca/secrets/` | `services/step-ca/config/` / `services/step-ca/secrets/` | Update backup/restores to use the new directories. The data volume remains `stepca-data`. |
| `step-ca/data/` | `stepca-data/` (Docker volume) | Container data now lives in a named volume declared in `compose/base.yml`. |
| `certs/*` | `shared/certs/*` | Local CA and leaf certificates now live under `shared/certs/`. |
| `certbot/conf/` / `certbot/www/` | `services/certbot/conf/` / `services/certbot/www/` | Certbot bind mounts continue to work once you copy your config into these directories. |

If you previously mounted `docker-compose.yml` or referenced it in scripts, point them at the layered compose files instead. The helper script `./scripts/compose.sh` already composes the right files and mirrors the old `docker compose` command line. For Traefik-specific templates, `scripts/traefik-render-dynamic.sh` now reads from `services/traefik/dynamic/`.
