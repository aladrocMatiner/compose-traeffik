## ADDED Requirements

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
