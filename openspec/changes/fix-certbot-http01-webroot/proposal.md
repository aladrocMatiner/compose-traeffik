# Change: Fix Certbot HTTP-01 Webroot Routing

## Summary
Make ACME HTTP-01 succeed for Certbot by serving the webroot path and routing `/.well-known/acme-challenge/` over HTTP without interfering with global HTTPS redirects.

## Problem
Certbot uses `--webroot`, but there is no service/router that serves `/.well-known/acme-challenge/`. As a result, HTTP-01 validation fails.

## Goals
- Provide a minimal static webroot service for ACME challenges.
- Add a Traefik HTTP router for `/.well-known/acme-challenge/` without HTTPS redirect on that path.
- Ensure Certbot scripts and the webroot service use the same webroot path.

## Non-goals
- No refactors or unrelated changes to TLS strategy or Traefik configuration.
- No changes outside the allowed files list for this change.

## Approach
- Add a minimal `certbot-web` service (e.g., `nginx:alpine`) that serves the shared webroot directory.
- Add Traefik labels for a high-priority HTTP router that matches `PathPrefix(`/.well-known/acme-challenge/`)`, targets `certbot-web`, and bypasses HTTPS redirect via a no-op middleware.
- Align `certbot-issue.sh` and `certbot-renew.sh` to the same webroot path used by the web service.

## Affected files
- `services/certbot/compose.yml` (or a new `services/certbot-web/compose.yml`)
- `services/traefik/compose.yml` (if labels are placed there instead)
- `scripts/certbot-issue.sh`
- `scripts/certbot-renew.sh`
- `docs/05-tls/mode-a-selfsigned.md` (only if needed to explain verification)

## Verification
- Create a file under the webroot and confirm:
  - `curl http://<domain>/.well-known/acme-challenge/test` returns the file content.
- Run `scripts/certbot-issue.sh` and confirm HTTP-01 succeeds (with DNS pointing at the host).
