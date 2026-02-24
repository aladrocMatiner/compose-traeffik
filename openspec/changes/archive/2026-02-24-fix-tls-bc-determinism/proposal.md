# Change: Make TLS Mode B/C deterministic and configurable via .env

## Why
Mode B and Mode C are currently inconsistent with the intended configuration. Traefik uses hard-coded ACME resolver settings, Certbot outputs are not mounted into Traefik (so issued certs are not served), and step-ca bootstrap accepts an unset DNS list, which can lead to empty SANs. These issues make TLS behavior non-deterministic and surprising when `DEV_DOMAIN` changes.

## Discovery Summary
- **Hard-coded ACME settings** in `services/traefik/traefik.yml`:
  - `email: you@example.com`
  - `caServer: https://acme-staging-v02.api.letsencrypt.org/directory`
  - `caServer: https://step-ca.local.test:9000/acme/acme/directory`
- **Certbot output** is written to `services/certbot/conf`, but Traefik only mounts `/certs` and `shared/certs/local` and does not read the certbot path.
- **Certbot scripts** issue with a `--cert-name` derived from `DEV_DOMAIN` and assume Traefik will pick it up.
- **Step-CA bootstrap** uses `STEP_CA_DNS` but `.env.example` does not define it and the script does not validate it.
- **Docs** already call out the step-ca URL mismatch and certbot hard-coded domains; these will need alignment once behavior is fixed.

## What Changes
- Parameterize Traefik ACME resolver `email` and `caServer` values from `.env`.
- Mount certbot output into the Traefik container and define file-provider TLS entries that point to the certbot certs when Mode B is used.
- Make step-ca bootstrap fail fast when `STEP_CA_DNS` is missing, and document a safe default.
- Update docs to match the new deterministic behavior (only where existing claims are currently wrong).

## Impact
- Affected specs: tls-mode-bc
- Affected files: `services/traefik/traefik.yml`, `services/traefik/compose.yml`, `services/traefik/dynamic/tls.yml`, `scripts/certbot-issue.sh`, `scripts/certbot-renew.sh`, `scripts/stepca-bootstrap.sh`, `.env.example`, relevant docs under `docs/`
