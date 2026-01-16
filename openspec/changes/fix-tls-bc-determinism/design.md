## Context
TLS Mode B and C are partially configured with hard-coded resolver values and do not fully integrate Certbot or step-ca. Deterministic behavior requires configuration via `.env` and consistent mounting of certificate outputs into Traefik.

## Goals / Non-Goals
- Goals:
  - Use `.env` for ACME email and CA server values.
  - Ensure Traefik can read Certbot outputs when Mode B is selected.
  - Ensure step-ca bootstrap has a validated, non-empty DNS list.
- Non-Goals:
  - Changing the certificate issuance flow outside Mode B/C.
  - Reworking Mode A local self-signed flow.

## Decisions
- Use `ACME_EMAIL` for both resolvers (LE and step-ca) to avoid hard-coded email.
- Replace hard-coded CA servers with env-driven values (`LETSENCRYPT_CA_SERVER` and a new step-ca ACME URL variable).
- Make Certbot the source of truth by mounting `services/certbot/conf` into Traefik and defining TLS file-provider certificates pointing to the Certbot live directory.
- Require `STEP_CA_DNS` and derive a safe default when missing (based on `DEV_DOMAIN` and service hostname).

## Risks / Trade-offs
- Traefik will log errors if certbot files do not exist; this must be mitigated by documenting workflow order and/or guarding with profile-specific instructions.
- Introducing a new env var for step-ca ACME URL requires documentation and migration guidance.

## Migration Plan
- Add env defaults in `.env.example` for step-ca DNS and ACME URL.
- Update Traefik static config to read env values for ACME.
- Mount certbot output into Traefik and update TLS dynamic config.
- Update Certbot scripts to use a deterministic cert name that matches the mounted path.
- Update docs to reflect the deterministic flow.

## Open Questions
- Should the step-ca ACME URL be derived from `DEV_DOMAIN` in the script or be a required explicit `.env` value?
- Is it acceptable to use `ACME_EMAIL` for both LE and step-ca, or should step-ca have a dedicated email variable?
