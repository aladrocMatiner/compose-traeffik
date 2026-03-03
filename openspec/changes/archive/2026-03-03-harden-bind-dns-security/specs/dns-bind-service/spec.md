## ADDED Requirements

### Requirement: BIND hardened runtime defaults
The system SHALL run BIND with hardened defaults that minimize attack surface for local authoritative DNS operation.

#### Scenario: Service starts with hardened options
- **WHEN** BIND is started through the `bind` profile
- **THEN** recursion is disabled
- **AND** zone transfer is denied by default
- **AND** metadata disclosure via CHAOS queries is minimized

#### Scenario: Configuration validated before daemon start
- **WHEN** the BIND container command executes
- **THEN** it validates the rendered configuration and target zone before launching `named`
- **AND** startup fails fast if validation fails

