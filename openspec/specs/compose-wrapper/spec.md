# compose-wrapper Specification

## Purpose
TBD - created by archiving change fix-compose-project-pin. Update Purpose after archive.
## Requirements
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

### Requirement: BIND lifecycle targets use deterministic compose wrapper
The system SHALL execute BIND lifecycle Make targets through the shared compose wrapper so project name and project directory remain deterministic regardless of current working directory.

#### Scenario: Operator runs command from alternate directory
- **WHEN** an operator executes `make bind-up` (or any BIND lifecycle target) from any CWD using the project Makefile
- **THEN** the command uses the pinned compose project settings
- **AND** reuses the expected project networks and volumes

#### Scenario: Profile and service scope are explicit
- **WHEN** a BIND lifecycle target is executed
- **THEN** compose is invoked with profile `bind`
- **AND** the target is scoped to BIND operations rather than unrelated services

