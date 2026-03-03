# deployment-cli Specification

## Purpose
TBD - created by archiving change add-ubuntu-lts-os-selectors. Update Purpose after archive.
## Requirements
### Requirement: `deployment-list-os` exposes Ubuntu LTS versioned selectors
The system SHALL include Ubuntu LTS versioned selectors in `make deployment-list-os` output using stable, script-friendly formatting.

#### Scenario: Operator lists supported deployment OS selectors
- **WHEN** an operator runs `make deployment-list-os`
- **THEN** output includes `ubuntu20.04`, `ubuntu22.04`, and `ubuntu24.04` as supported selectors
- **AND** output remains one selector token per line with exit status `0`

### Requirement: CLI help documents Ubuntu selector compatibility contract
The system SHALL document Ubuntu selector behavior in deployment command help text, including backward compatibility for legacy selector `ubuntu`.

#### Scenario: Operator checks deployment selector help
- **WHEN** an operator reads `make help` deployment selector guidance
- **THEN** help text includes `ubuntu20.04`, `ubuntu22.04`, and `ubuntu24.04`
- **AND** help text states the compatibility mapping for `ubuntu` selector

### Requirement: Make target `deployment-list-os` exposes supported deployment OS selectors
The system SHALL provide a Make target `deployment-list-os` that prints the deployment OS selectors supported by the deployment workflow in a stable, script-friendly format.

#### Scenario: Operator lists supported OS selectors
- **WHEN** an operator runs `make deployment-list-os`
- **THEN** the command prints one supported OS selector per line in stable order
- **AND** the command exits with status `0` without requiring Terraform state or active VM resources

#### Scenario: Output can be consumed by scripts
- **WHEN** an operator pipes `make deployment-list-os` output to shell tooling
- **THEN** each line contains a single selector token
- **AND** no extra explanatory text is required to parse the list

### Requirement: Make target `deployment-list-targets` exposes currently supported deployment targets
The system SHALL provide a Make target `deployment-list-targets` that prints the deployment target selectors supported by the current phase in a stable, script-friendly format.

#### Scenario: Operator lists supported deployment targets
- **WHEN** an operator runs `make deployment-list-targets`
- **THEN** the command prints one supported target selector per line in stable order
- **AND** the command exits with status `0` without requiring Terraform state or active VM resources

#### Scenario: Current phase target scope is explicit
- **WHEN** an operator runs `make deployment-list-targets` in this phase
- **THEN** the output contains `qemu`
- **AND** no unsupported target is listed as available in this command output

