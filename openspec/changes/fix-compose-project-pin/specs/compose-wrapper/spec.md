## ADDED Requirements
### Requirement: Deterministic compose project
The system SHALL pin the compose project name and project directory so that commands run from any CWD reuse the same project, networks, and volumes.

#### Scenario: Different CWD
- **WHEN** a compose command is run from a different working directory
- **THEN** the same compose project name and resources are used

### Requirement: Functional ps target
The system SHALL provide a working `make ps` target that lists running services using the standard compose wrapper.

#### Scenario: make ps
- **WHEN** a user runs `make ps`
- **THEN** the command executes successfully and lists services

