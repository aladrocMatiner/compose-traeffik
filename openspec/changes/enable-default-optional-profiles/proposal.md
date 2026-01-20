# Change: Enable default optional profiles and UIs

## Why
- New users currently need to edit `.env` and create htpasswd files before they can see the Traefik dashboard, DNS UI, or Step-CA UI, which reduces the value of the quickstart.
- Enabling the optional profiles by default removes manual steps while the bootstrap script already covers secrets, so we get the benefit of the UIs without additional action.

## What Changes
- Update the env defaults (via `.env.example` and `make bootstrap`) so that Traefik dashboard, DNS, Certbot, and Step-CA profiles are enabled out of the box and their BasicAuth wiring points to concrete files.
- Teach `scripts/env-generate.sh` (or a related bootstrap step) to provision the required htpasswd files and secrets so the preflight helper is satisfied.
- Document the new defaults in the README/operational docs and ensure the tests/documentation align with the activated profiles.

## Impact
- Affected specs: environment defaults and bootstrapping
- Affected code: `.env.example`, `scripts/env-generate.sh`, `services/traefik/auth/*`, README/docs referencing defaults
