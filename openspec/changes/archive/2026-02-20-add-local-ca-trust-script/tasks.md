- [x] Title: Define trust install scope
  Files: `openspec/changes/add-local-ca-trust-script/proposal.md`
  Acceptance: OS scope is specified (e.g., Ubuntu 24.04) and CA path is `shared/certs/local-ca/ca.crt`.

- [x] Title: Implement local CA trust scripts
  Files: `scripts/local-ca-trust-install.sh`, `scripts/local-ca-trust-uninstall.sh`, `scripts/local-ca-trust-verify.sh`
  Acceptance: Scripts mirror the step‑ca trust flow and operate on the local CA path.

- [x] Title: Add Make targets
  Files: `Makefile`
  Acceptance: Targets exist to install/uninstall/verify local CA trust.

- [x] Title: Update Mode A documentation
  Files: `docs/05-tls/mode-a-selfsigned.md`
  Acceptance: Docs include the new trust commands and mention the CA path.

- [x] Title: Verification checklist
  Files: `openspec/changes/add-local-ca-trust-script/proposal.md`
  Acceptance: Checklist confirms trust store updates and verification steps.
