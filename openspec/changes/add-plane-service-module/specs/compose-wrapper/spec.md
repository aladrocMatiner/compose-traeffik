## ADDED Requirements
### Requirement: Plane module lifecycle targets use the shared compose wrapper
The system SHALL provide Plane module lifecycle targets that use `scripts/compose.sh` and the `plane` profile, preserving deterministic compose project behavior.

#### Scenario: Plane lifecycle commands
- **WHEN** a user runs `make plane-up`, `make plane-down`, or `make plane-status`
- **THEN** commands execute through the shared compose wrapper with `--profile plane`
- **AND** they operate only on Plane module services

#### Scenario: Plane smoke target
- **WHEN** a user runs `make test-plane`
- **THEN** only Plane-specific smoke tests are executed using the repository test wrappers
