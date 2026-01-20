# Change: Unify CA configuration via .env

## Why
CA metadata is currently defined in multiple places (Mode A hardcoded in `certs-selfsigned-generate.sh`, Mode C in `.env`). This creates drift and makes it harder to keep certificate subjects and SANs consistent.

## What Changes
- Add a shared CA configuration section in `.env.example` (and documented for `.env`) with canonical CA name and SAN values.
- Update Mode A (self-signed) generation to read CA subject/SAN values from the shared `.env` section.
- Update Mode C (step-ca bootstrap) to read CA name and DNS/SAN values from the same shared `.env` section (with fallbacks for existing `STEP_CA_*` variables).
- Update docs to explain the shared CA configuration and how it affects Mode A and Mode C.

## Impact
- Affected specs: `specs/tls-ca-config/spec.md` (new capability)
- Affected code/docs: `.env.example`, `scripts/certs-selfsigned-generate.sh`, `scripts/stepca-bootstrap.sh`, `docs/05-tls/mode-a-selfsigned.md`, `docs/05-tls/mode-c-stepca-acme.md`, `README.*`, `scripts/env-generate.sh` (if it seeds defaults)
