## ADDED Requirements

### Requirement: Semaphore UI lifecycle targets use the compose wrapper pattern
The system SHALL provide Semaphore UI lifecycle Make targets that invoke the standard compose wrapper with the `semaphoreui` profile.

#### Scenario: Semaphore UI lifecycle command
- **WHEN** a user runs `make semaphoreui-up` (or related lifecycle targets)
- **THEN** the command executes through `scripts/compose.sh`
- **AND** the `semaphoreui` profile is enabled for the compose invocation

### Requirement: Semaphore UI service-specific smoke test target
The system SHALL provide a dedicated `make test-semaphoreui` target for Semaphore UI static smoke tests.

#### Scenario: Service-specific test invocation
- **WHEN** a user runs `make test-semaphoreui`
- **THEN** only Semaphore UI service smoke tests are executed
- **AND** the command does not require the Semaphore UI runtime stack to be running

### Requirement: Semaphore UI smoke tests integrate with the repository test runner conventions
The system SHALL integrate Semaphore UI smoke tests with the repository's standard `make test`/`scripts/healthcheck.sh` conventions used by the current branch.

#### Scenario: Branch-level smoke test runner includes Semaphore UI checks
- **WHEN** a contributor runs the branch-standard smoke test runner (`make test` or equivalent wrapper)
- **THEN** Semaphore UI smoke tests are included according to the branch's documented test-runner behavior
- **AND** the test documentation inventory matches the implemented wiring
