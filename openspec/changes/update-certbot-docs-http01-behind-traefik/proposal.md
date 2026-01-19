# Change: Update Certbot Docs for HTTP-01 Behind Traefik

## Summary
Update Certbot and Mode‑B TLS documentation to match the current HTTP‑01 flow where Traefik serves the challenge via `certbot-web` and Certbot uses `--webroot` without binding 80/443.

## Problem
Docs still state that Certbot scripts bind `80:80`/`443:443` and recommend stopping the stack. This is no longer accurate after routing `/.well-known/acme-challenge/` through Traefik to `certbot-web`. The mismatch can mislead operators and cause avoidable downtime.

## Goals
- Replace “bind 80/443” claims with the correct Traefik + `certbot-web` flow.
- Update Mode‑B guides to keep Traefik running and to require the `le` profile so `certbot-web` is up.
- Make the updated flow explicit and consistent across EN/ES/SV docs.

## Non-goals
- No runtime or compose changes.
- No changes to historical OpenSpec proposals or unrelated docs.

## Approach
- In Certbot READMEs (EN/ES/SV), replace “bind 80/443” with: Traefik routes `/.well-known/acme-challenge/` to `certbot-web`, and Certbot uses `--webroot`.
- In Mode‑B docs, replace “stop the stack” guidance with: keep Traefik running and ensure the `le` profile is up (e.g., `COMPOSE_PROFILES=le make up`) so `certbot-web` serves the challenge.
- Explicitly mention that Certbot does not bind 80/443 directly in the current flow.

## Affected files
- `services/certbot/README.md`
- `services/certbot/README.es.md`
- `services/certbot/README.sv.md`
- `docs/tls-mode-b-letsencrypt-certbot.md`
- `docs/05-tls/mode-b-letsencrypt-certbot.md`

## Verification
- Certbot READMEs no longer claim direct 80/443 binds and mention Traefik + `certbot-web` webroot routing.
- Mode‑B docs instruct keeping Traefik up and enabling the `le` profile for issuance/renewal.
