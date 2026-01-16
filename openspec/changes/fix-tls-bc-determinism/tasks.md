## 1. Implementation
- [x] 1.1 Confirm naming for step-ca ACME URL env var and certbot cert-name strategy.
- [x] 1.2 Update `services/traefik/traefik.yml` to read ACME email and CA server values from env.
- [x] 1.3 Update `services/traefik/compose.yml` to mount Certbot output into Traefik (read-only).
- [x] 1.4 Update `services/traefik/dynamic/tls.yml` to include certbot cert paths for Mode B.
- [x] 1.5 Update `scripts/certbot-issue.sh` and `scripts/certbot-renew.sh` to use the deterministic cert name/path.
- [x] 1.6 Update `scripts/stepca-bootstrap.sh` to validate `STEP_CA_DNS` and set a safe default when missing.
- [x] 1.7 Update `.env.example` with any new variables and default guidance.
- [x] 1.8 Update docs under `docs/` that reference hard-coded CA URLs or certbot pickup behavior.

## 2. Validation
- [x] 2.1 Validate that changing `DEV_DOMAIN` updates step-ca ACME URL and certbot paths without manual edits.
- [x] 2.2 Confirm Traefik serves certbot-issued certs when Mode B is selected.
