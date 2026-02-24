## 1. Implementation
- [x] Confirm current HTTP-01 gap.  
  Files: `services/certbot/compose.yml`, `scripts/certbot-issue.sh`, `scripts/certbot-renew.sh`  
  Acceptance: ACME HTTP-01 failure cause is documented as missing webroot-serving route for `/.well-known/acme-challenge/`.

- [x] Define the canonical webroot path.  
  Files: `services/certbot/compose.yml`, `scripts/certbot-issue.sh`, `scripts/certbot-renew.sh`  
  Acceptance: Single webroot path is specified (host `services/certbot/www`, container `/var/www/certbot`).

- [x] Add minimal certbot-web service.  
  Files: `services/certbot/compose.yml`  
  Acceptance: `certbot-web` serves the webroot directory and joins the Traefik proxy network.

- [x] Add Traefik HTTP router for ACME path.  
  Files: `services/certbot/compose.yml`  
  Acceptance: Router matches `PathPrefix(\`/.well-known/acme-challenge/\`)`, uses `web` entrypoint, high priority, and bypasses HTTPS redirect.

- [x] Align Certbot scripts to webroot.  
  Files: `scripts/certbot-issue.sh`, `scripts/certbot-renew.sh`  
  Acceptance: Both scripts use the same webroot path as `certbot-web`.

- [x] Document HTTP-01 verification (not applicable).  
  Files: `docs/05-tls/mode-a-selfsigned.md`  
  Acceptance: Not applicable for Mode A docs; no change required.

## 2. Verification
- [x] Manual verification defined.  
  Files: `openspec/changes/fix-certbot-http01-webroot/proposal.md`  
  Acceptance: Checklist includes creating a webroot file and confirming `curl http://<domain>/.well-known/acme-challenge/<file>` returns its content.
