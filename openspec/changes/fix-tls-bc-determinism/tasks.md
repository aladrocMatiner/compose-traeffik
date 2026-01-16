## 1. Implementation
- [ ] 1.1 Confirm naming for step-ca ACME URL env var and certbot cert-name strategy.
- [ ] 1.2 Update `services/traefik/traefik.yml` to read ACME email and CA server values from env.
- [ ] 1.3 Update `services/traefik/compose.yml` to mount Certbot output into Traefik (read-only).
- [ ] 1.4 Update `services/traefik/dynamic/tls.yml` to include certbot cert paths for Mode B.
- [ ] 1.5 Update `scripts/certbot-issue.sh` and `scripts/certbot-renew.sh` to use the deterministic cert name/path.
- [ ] 1.6 Update `scripts/stepca-bootstrap.sh` to validate `STEP_CA_DNS` and set a safe default when missing.
- [ ] 1.7 Update `.env.example` with any new variables and default guidance.
- [ ] 1.8 Update docs under `docs/` that reference hard-coded CA URLs or certbot pickup behavior.

## 2. Validation
- [ ] 2.1 Validate that changing `DEV_DOMAIN` updates step-ca ACME URL and certbot paths without manual edits.
- [ ] 2.2 Confirm Traefik serves certbot-issued certs when Mode B is selected.
