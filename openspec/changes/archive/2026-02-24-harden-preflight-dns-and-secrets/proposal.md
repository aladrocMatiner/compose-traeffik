# Change: Harden preflight validation for DNS and auth secrets

## Why
Current entrypoints bypass preflight checks, allowing weak/default credentials and invalid auth paths. This creates avoidable security risk and inconsistent behavior when running DNS or dashboard routes.

## What Changes
- Route all compose entrypoints (including DNS targets) through preflight validation to fail early on unsafe config.
- Tighten auth file validation to container-visible paths only and require non-example htpasswd files when admin UIs are enabled.
- Enforce non-placeholder DNS admin password when the DNS profile is enabled.
- Prevent accidental commits of real htpasswd files via `.gitignore`.
- Document the preflight script and relevant variables in `scripts/README.md`.

## Impact
- **Security**: Enforces fail-closed auth defaults and prevents weak DNS admin credentials.
- **Developer workflow**: `make dns-*` and other compose entrypoints will fail early with clear messages when misconfigured.
- **Docs**: Updates operational script documentation to reflect preflight checks.

## Discovery Summary
- DNS targets (`dns-up/down/logs/status`) call docker compose directly and do not run `scripts/validate-env.sh`.
- Only `services/traefik/auth/dns-ui.htpasswd` is ignored; dashboard htpasswd can be committed.
- `.env.example` ships `DNS_ADMIN_PASSWORD=change-me` which currently passes validation.
- `services/traefik/compose.yml` only mounts `./services/traefik/auth` to `/etc/traefik/auth`, but `scripts/validate-env.sh` accepts arbitrary host paths.
- `scripts/README.md` does not mention `scripts/validate-env.sh` or the htpasswd env vars.
