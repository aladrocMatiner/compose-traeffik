## 1. OpenSpec Contract

- [x] 1.1 Confirm scope for Ubuntu LTS versioned selectors (`ubuntu20.04`, `ubuntu22.04`, `ubuntu24.04`) under `vm-provisioning`.
- [x] 1.2 Confirm backward-compatibility behavior for legacy selector `ubuntu`.
- [x] 1.3 Confirm discovery output contract update for `deployment-list-os`.
- [x] 1.4 Validate change artifacts with `openspec validate add-ubuntu-lts-os-selectors --strict`.

## 2. Provisioning OS Profile Extension

- [x] 2.1 Extend provisioning selector validation to accept `ubuntu20.04`, `ubuntu22.04`, `ubuntu24.04`.
- [x] 2.2 Implement deterministic alias mapping from `ubuntu` to `ubuntu24.04`.
- [x] 2.3 Define pinned image metadata (URL/path/checksum strategy) per Ubuntu LTS selector.
- [x] 2.4 Ensure VM naming and SSH-user defaults remain deterministic for each Ubuntu selector.

## 3. Bootstrap and Wait Script Compatibility

- [x] 3.1 Update `host-wait-ssh.sh` selector validation for the new Ubuntu LTS selectors.
- [x] 3.2 Update `host-bootstrap.sh` selector validation and Ubuntu-family gating for apt-based Docker bootstrap.
- [x] 3.3 Update `host-bootstrap-check.sh` selector validation and readiness checks for versioned Ubuntu selectors.
- [x] 3.4 Keep fail-fast messages clear for unsupported selectors/target combinations.

## 4. Makefile and CLI Discovery Contract

- [x] 4.1 Update `DEPLOYMENT_SUPPORTED_OS_SELECTORS` to include Ubuntu LTS versioned selectors.
- [x] 4.2 Update `make help` selector syntax/examples to include the new Ubuntu selectors and alias behavior.
- [x] 4.3 Keep output of `deployment-list-os` stable and script-friendly (one selector per line).

## 5. Tests and Documentation

- [x] 5.1 Update smoke tests for deployment selector/list command contract.
- [x] 5.2 Add or update tests for alias behavior (`ubuntu` -> `ubuntu24.04`) and selector guardrails.
- [x] 5.3 Update deployment docs with Ubuntu LTS selector matrix and migration notes.

## 6. Validation and Handoff

- [x] 6.1 Re-run `openspec validate add-ubuntu-lts-os-selectors --strict`.
- [x] 6.2 Run affected smoke tests and capture evidence for selector contract stability.
- [x] 6.3 Verify consistency across proposal/design/tasks/spec deltas.
