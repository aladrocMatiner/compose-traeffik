# Change: Add Local CA Trust Script for Mode A

## Summary
Provide a script and Make target to install/uninstall the local self‑signed CA for Mode A.

## Problem
Mode A relies on a local CA at `shared/certs/local-ca/ca.crt`, but there is no automated trust-install workflow. Users must manually trust the CA, which is easy to miss and causes TLS verification failures.

## Goals
- Add an explicit script to trust the Mode A CA on the host OS (initially Ubuntu 24.04, matching existing Step‑CA trust scripts).
- Provide Make targets to install/uninstall/verify the local CA trust.
- Document the new workflow in Mode A docs.

## Non-goals
- No changes to Step‑CA trust flow.
- No cross‑platform support beyond the documented OS.

## Approach
- Create a `scripts/local-ca-trust-install.sh` (and uninstall/verify) patterned after existing `stepca-trust-*` scripts.
- Add Make targets (`local-ca-trust-install`, `local-ca-trust-uninstall`, `local-ca-trust-verify`).
- Update Mode A docs to reference the trust script.

## Affected files
- `scripts/local-ca-trust-install.sh`
- `scripts/local-ca-trust-uninstall.sh`
- `scripts/local-ca-trust-verify.sh`
- `Makefile`
- `docs/05-tls/mode-a-selfsigned.md`

## Verification
- Running the install script adds the CA to the system trust store.
- `openssl verify` against `shared/certs/local-ca/ca.crt` succeeds after install.
