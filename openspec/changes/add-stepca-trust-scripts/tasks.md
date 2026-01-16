## 1. Implementation
- [x] 1.1 Add `scripts/stepca-trust-install.sh` for Ubuntu 24.04 system trust install.
- [x] 1.2 Add `scripts/stepca-trust-uninstall.sh` to remove the installed CA from the system trust store.
- [x] 1.3 Add `scripts/stepca-trust-verify.sh` to verify OS trust for the Step-CA root CA.
- [x] 1.4 Add Makefile targets `stepca-trust-install`, `stepca-trust-uninstall`, `stepca-trust-verify`.
- [x] 1.5 Update docs to describe trust installation, verification, and security boundaries.

## 2. Validation
- [ ] 2.1 Run `shellcheck` on the new scripts (if available).
- [ ] 2.2 Manual verify: install, verify, uninstall, verify (Ubuntu 24.04).
