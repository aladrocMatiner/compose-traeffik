## 1. Discovery
- [x] 1.1 Record current Traefik mounts, auth references, and dynamic config file layout.
- [x] 1.2 Record current env vars used by routing/auth/toggles from `.env.example`.
- [x] 1.3 Record current tests/healthcheck toggle usage and router labels.

## 2. Implementation
- [x] 2.1 Add a mounted auth directory and example users file; update middlewares to use usersFile for DNS UI and dashboard.
  - Acceptance: Fresh run with example users file returns 401 (not 404) for DNS UI and dashboard routes.
- [x] 2.2 Secure dashboard defaults (HTTPS only, no host port exposure) and document how to enable/generate users file.
  - Acceptance: No host port 8080 is exposed; dashboard only routed via HTTPS + auth.
- [x] 2.3 Gate certbot TLS config by splitting base TLS vs Mode B TLS and loading Mode B only when enabled.
  - Acceptance: Traefik logs contain no certbot parse errors when Mode B disabled; Mode B loads certbot certs when enabled.
- [x] 2.4 Align redirect toggle usage across `scripts/healthcheck.sh` and tests with `HTTP_TO_HTTPS_MIDDLEWARE` (fallback to legacy var).
  - Acceptance: Healthcheck and tests read the same toggle used by router labels.
- [x] 2.5 Update `README.md` with short notes for auth file generation and dashboard enablement.
  - Acceptance: README includes a brief, accurate instruction block without new behaviors.

## 3. Validation
- [x] 3.1 Verify DNS UI and dashboard auth with example users file on a fresh run (no 404).
- [x] 3.2 Verify Traefik logs show no certbot TLS parse errors when Mode B is disabled.
- [x] 3.3 Verify redirect toggle behavior via `make test` (or direct smoke test if more appropriate).
