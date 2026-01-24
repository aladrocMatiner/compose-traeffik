# OpenSpec Proposal: Add Open WebUI Integration

## Summary
Integrate the official **Open WebUI** image as a first‑class service in the Traefik‑based stack.  The integration will:

1. Expose the UI behind Traefik via a dedicated subdomain.
2. Persist state in a named Docker volume (`openwebui_data`).
3. Use `.env.example` for configuration and follow existing domain/network conventions.
4. Add documentation, README entries, and minimal registration into the repo’s service enablement mechanism.

The proposal follows the project’s OpenSpec guidelines and builds on patterns already used by other services (e.g., certbot, dns).  All changes are non‑destructive and can be reviewed/approved before application.

## Change ID
`add-openwebui-integration`
