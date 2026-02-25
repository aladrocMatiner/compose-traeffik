## MODIFIED Requirements
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

### Requirement: Service module lifecycle targets use the compose wrapper pattern
New optional service modules SHALL expose lifecycle Make targets that route through the shared compose wrapper with explicit profile selection.

#### Scenario: Keycloak lifecycle target
- **WHEN** a user runs `make keycloak-up` (or `down`, `restart`, `logs`, `status`)
- **THEN** the command uses the repository compose wrapper with the `keycloak` profile
- **AND** preserves deterministic project behavior and env loading

#### Scenario: Keycloak service test target
- **WHEN** a user runs `make test-keycloak`
- **THEN** the command runs Keycloak service-specific smoke tests without requiring unrelated service suites by default
- **AND** the target follows the repository's documented test partitioning pattern for service modules when present
