## Context
The stack is Traefik-centered with local development domains. We need a single source of truth for endpoint hostnames, a secure DNS UI via Traefik, and a reliable way to configure Ubuntu 24.04 split-DNS for the project domain.

## Goals / Non-Goals
- Goals:
  - Use a DNS service with a web UI exposed only via Traefik HTTPS and protected by auth.
  - Keep port 53 bound to localhost by default for safe-by-default behavior.
  - Provide idempotent provisioning of DNS records based on ENDPOINTS and loopback IPs.
  - Provide Ubuntu 24.04 split-DNS configuration using systemd-resolved.
- Non-Goals:
  - Support non-Ubuntu operating systems in automation scripts.
  - Provide public/external DNS exposure or production hardening.

## Decisions
- DNS service: Technitium DNS Server (official image `technitium/dns-server:latest`, UI default HTTP port 5380, config volume `/etc/dns`).
- UI exposure: Only via Traefik router on `websecure` with TLS; DNS UI ports not published to host.
- Auth: Traefik BasicAuth middleware with htpasswd file path configured via env; optional IP allowlist middleware toggled by env.
- DNS records: Use deterministic A record assignment `127.0.<LOOPBACK_X>.<y>` with `y=1..N` and reserve `y=254` for `dns.<BASE_DOMAIN>`.
- Ubuntu DNS config: Use `resolvectl` split-DNS for the default route interface; do not overwrite `/etc/resolv.conf`.

## Risks / Trade-offs
- Technitium API automation requires a token; provisioning script must manage login/token or accept a pre-created token.
- DNS port 53 may conflict with local resolvers; documentation must guide conflict resolution.

## Migration Plan
- Add new env defaults and scripts.
- Enable dns profile and run provisioning before configuring systemd-resolved.
- Provide explicit rollback steps in docs and `dns-configure-ubuntu.sh remove`.

## Open Questions
- Confirm Technitium API endpoints and required auth flow for record provisioning (login vs API token).
- Confirm whether to store an API token in `.env` or derive one at runtime.
