## ADDED Requirements
### Requirement: Observability lifecycle targets include advanced signal services
The system SHALL provide Makefile wrappers for advanced observability lifecycle commands through `scripts/compose.sh` while preserving deterministic compose project behavior.

#### Scenario: Observability lifecycle with advanced services
- **WHEN** a user runs observability lifecycle targets (up, down, restart, logs, status)
- **THEN** Tempo and Pyroscope are managed together with existing observability services through `scripts/compose.sh --profile observability`
- **AND** commands reuse the same compose project identity across working directories

#### Scenario: Synthetic check target uses repository wrappers
- **WHEN** a user runs the k6 synthetic check Make target
- **THEN** execution uses repository wrapper conventions (env loading, profile handling, and compose wiring) without ad-hoc local commands
