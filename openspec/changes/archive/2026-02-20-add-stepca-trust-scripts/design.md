## Context
We run a local Step-CA service (profile `stepca`). The root CA certificate must be trusted by the host OS to avoid TLS errors. The root CA cert is public, but the CA private key and passwords are sensitive and must never be exposed or copied outside the Step-CA container/volume.

## Goals / Non-Goals
- Goals:
  - Install/uninstall the Step-CA root CA into Ubuntu 24.04 system trust store.
  - Verify that OS trust is correctly established.
  - Avoid handling any sensitive material (private keys, passwords).
- Non-Goals:
  - Support non-Ubuntu platforms (for now).
  - Manage Step-CA provisioning or CA rotation.

## Decisions
- Decision: Source the CA certificate from an existing public artifact only (e.g., `./step-ca/config/ca.crt` or a safe container export), never from secrets directories or key material.
- Decision: Use Ubuntu system trust store (`/usr/local/share/ca-certificates` + `update-ca-certificates`) for installation.
- Decision: Verification checks both presence in trust store and cryptographic verification against the system bundle.

## Risks / Trade-offs
- Risk: Running as root is required to modify trust store. Mitigation: keep operations minimal and restricted to public CA cert.
- Risk: Missing or stale CA cert on disk. Mitigation: clear error messaging and guidance to bootstrap/copy the CA cert first.

## Migration Plan
- None required; scripts are additive.

## Open Questions
- None.
