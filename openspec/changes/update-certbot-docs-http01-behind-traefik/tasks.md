## 1. Implementation
- [x] Identify outdated Certbot port-bind statements.  
  Files: `services/certbot/README.md`, `services/certbot/README.es.md`, `services/certbot/README.sv.md`  
  Acceptance: Each README line claiming `80:80`/`443:443` binds is located.

- [x] Update Certbot README (EN).  
  Files: `services/certbot/README.md`  
  Acceptance: EN doc states Traefik routes `/.well-known/acme-challenge/` to `certbot-web` and Certbot uses `--webroot` (no direct port binds).

- [x] Update Certbot README (ES).  
  Files: `services/certbot/README.es.md`  
  Acceptance: ES doc mirrors the EN correction for Traefik + `certbot-web` and no direct 80/443 binds.

- [x] Update Certbot README (SV).  
  Files: `services/certbot/README.sv.md`  
  Acceptance: SV doc mirrors the EN correction for Traefik + `certbot-web` and no direct 80/443 binds.

- [x] Update Mode‑B TLS docs.  
  Files: `docs/tls-mode-b-letsencrypt-certbot.md`, `docs/05-tls/mode-b-letsencrypt-certbot.md`  
  Acceptance: Docs instruct keeping Traefik up and enabling the `le` profile so `certbot-web` serves the challenge.

## 2. Verification
- [x] Verification checklist.  
  Files: `openspec/changes/update-certbot-docs-http01-behind-traefik/proposal.md`  
  Acceptance: Checklist confirms no “stop stack” guidance remains and the `le` profile requirement is explicit.
