## MODIFIED Requirements
### Requirement: Scripts inventory and usage docs
The repository SHALL document operational scripts in `scripts/README.md` with purpose, invocation, prerequisites, and notable environment variables.

#### Scenario: Contributor inspects scripts docs
- **WHEN** a contributor reads `scripts/README.md`
- **THEN** they can understand what each major script does and how to run it safely
- **AND** AWX/k3d scripts list Kubernetes tooling prerequisites and destructive-vs-non-destructive semantics

### Requirement: Bootstrap scripts are documented
Bootstrap-related scripts SHALL document idempotency behavior and secret generation/rotation semantics.

#### Scenario: Bootstrap script behavior
- **WHEN** a user reads the documentation for a bootstrap script
- **THEN** they can tell which values are auto-generated, persisted, and when `--force` (or equivalent) is required to rotate them
- **AND** AWX bootstrap scripts follow the same documentation pattern when introduced
