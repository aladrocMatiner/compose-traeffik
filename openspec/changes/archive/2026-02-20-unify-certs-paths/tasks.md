## 1. Implementation
- [x] Inventory certs path usage in allowed files.
- [x] Define CERTS_DIR=shared/certs in Makefile and use it where applicable.
- [x] Update self-signed cert generation paths to use CERTS_DIR.
- [x] Update Traefik cert mounts to use CERTS_DIR. (No change needed; already uses shared/certs.)
- [x] Update TLS smoke test CA path to use CERTS_DIR.
- [x] Update TLS documentation to reference shared/certs.

## 2. Verification
- [x] Confirm all paths reference shared/certs and no certs/ references remain in allowed files.
