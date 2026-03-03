# tests-docs Specification

## Purpose
TBD - created by archiving change docs-smoke-tests. Update Purpose after archive.
## Requirements
### Requirement: Smoke test documentation
The system SHALL document smoke tests in `tests/README.md` with purpose, run instructions, inventory, configuration, expected output, and troubleshooting. Service modules such as GitLab SHALL include module-specific smoke test entry points and prerequisites.

#### Scenario: Documentation completeness
- **WHEN** a user reads `tests/README.md`
- **THEN** they can understand what each test validates and how to interpret failures

#### Scenario: GitLab test entry points documented
- **WHEN** GitLab is available as a service module
- **THEN** `tests/README.md` documents `make test-gitlab`, required `.env` state, and any runtime test limitations

### Requirement: README link to tests
The system SHALL link to `tests/README.md` from the root README.

#### Scenario: Discoverability
- **WHEN** a user reads the root README
- **THEN** they can find a direct link to the smoke test documentation

### Requirement: DNS security test documentation
The system SHALL document DNS security smoke tests in `tests/README.md`, including prerequisites, expected pass/fail signals, and troubleshooting guidance.

#### Scenario: Contributor investigates a DNS security failure
- **WHEN** a DNS security smoke test fails
- **THEN** `tests/README.md` provides actionable diagnostics and remediation steps
- **AND** the documented inventory matches the tests executed by `scripts/healthcheck.sh`

### Requirement: Service-scoped test command documentation
The smoke test documentation SHALL describe service-scoped `make test-*` commands and explain the service-aware behavior of `make test`.

#### Scenario: Contributor chooses a targeted suite
- **WHEN** a contributor reads `tests/README.md` to run smoke tests for a specific module
- **THEN** the documentation lists the relevant `make test-*` commands
- **AND** indicates that `make test` auto-selects suites based on running services

#### Scenario: Contributor interprets skipped suites
- **WHEN** a contributor sees skipped suite messages during `make test`
- **THEN** `tests/README.md` explains that service-specific suites are skipped when their services are not running

### Requirement: Rocket.Chat static smoke suite documentation
The system SHALL document the Rocket.Chat static smoke suite in `tests/README.md`, including what it validates and how to run it.

#### Scenario: Contributor runs Rocket.Chat static checks
- **WHEN** a contributor reads `tests/README.md`
- **THEN** they can run `make test-rocketchat`
- **AND** they understand that the suite validates wiring/guardrails/rendering rather than a full Rocket.Chat runtime flow

### Requirement: Semaphore UI smoke test documentation
The system SHALL document Semaphore UI smoke tests and runtime validation guidance in `tests/README.md`.

#### Scenario: Semaphore UI test guidance
- **WHEN** a contributor reads `tests/README.md`
- **THEN** they can identify Semaphore UI smoke tests, how to run `make test-semaphoreui`, and how to interpret common failures

