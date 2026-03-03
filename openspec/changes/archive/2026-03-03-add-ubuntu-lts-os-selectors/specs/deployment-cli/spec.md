## ADDED Requirements

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
