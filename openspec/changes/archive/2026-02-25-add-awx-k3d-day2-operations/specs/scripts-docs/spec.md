## MODIFIED Requirements
### Requirement: Scripts inventory and usage docs
The repository SHALL document operational scripts in `scripts/README.md` with purpose, invocation, prerequisites, and notable environment variables.

#### Scenario: Contributor inspects scripts docs
- **WHEN** a contributor reads `scripts/README.md`
- **THEN** they can understand what each major script does and how to run it safely

### Requirement: Bootstrap scripts are documented
Bootstrap-related scripts SHALL document idempotency behavior and secret generation/rotation semantics.

#### Scenario: Bootstrap script behavior
- **WHEN** a user reads the documentation for a bootstrap script
- **THEN** they can tell which values are auto-generated, persisted, and when `--force` (or equivalent) is required to rotate them

### Requirement: Day-2 scripts include risk notes
Stateful service maintenance scripts (for example AWX backup/restore/upgrade) SHALL be documented with risk notes, prerequisites, and post-action verification steps.

#### Scenario: Restore script documentation
- **WHEN** a user reads the docs for an AWX restore script
- **THEN** the documentation identifies destructive effects, required confirmations, and post-restore checks
