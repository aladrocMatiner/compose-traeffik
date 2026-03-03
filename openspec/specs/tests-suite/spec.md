# tests-suite Specification

## Purpose
TBD - created by archiving change document-make-test-suite-table. Update Purpose after archive.
## Requirements
### Requirement: Smoke test inventory is presented as a standard table
The documentation for `make test` SHALL include a table that lists each smoke test script executed by `scripts/healthcheck.sh` and describes its purpose, prerequisites, and expected signal. The table SHALL cover all current scripts in `tests/smoke/`, including service-specific suites such as GitLab, and provide a consistent, scan-friendly format.

#### Scenario: Contributor scans the test suite
- **WHEN** a contributor opens `tests/README.md` to understand `make test`
- **THEN** they see a table enumerating each smoke test script with its purpose, prerequisites, and expected output
- **AND** the list matches the scripts invoked by `scripts/healthcheck.sh`

#### Scenario: GitLab suite is documented
- **WHEN** the GitLab module is added
- **THEN** `tests/README.md` documents the GitLab smoke tests and `make test-gitlab`
- **AND** shared runner documentation explains when the GitLab suite is executed

### Requirement: DNS security smoke coverage
The system SHALL include DNS security smoke tests that verify recursion denial, AXFR denial, metadata minimization, provisioning-input validation, and listener-scope behavior.

#### Scenario: Security checks execute in smoke suite
- **WHEN** `make test` runs
- **THEN** DNS security smoke tests execute as part of `scripts/healthcheck.sh`
- **AND** failures are reported with explicit per-test signals

### Requirement: Service-aware smoke suite selection
The smoke test runner (`scripts/healthcheck.sh`) SHALL group smoke tests into common and service-specific suites and select service-specific suites based on which compose services are running.

#### Scenario: No service containers running
- **WHEN** `scripts/healthcheck.sh` runs and no supported service containers are detected as running
- **THEN** it skips service-specific suites
- **AND** it still runs common utility smoke tests that do not require optional service containers

#### Scenario: Observability suite enabled by running services
- **WHEN** `scripts/healthcheck.sh` detects one or more observability services running (`grafana`, `prometheus`, `loki`, or `alloy`)
- **THEN** it executes the observability smoke suite
- **AND** it does not require unrelated suites (such as BIND) to run

### Requirement: Service-specific static smoke suites
The system SHALL support documented service-specific static smoke suites in addition to the default `make test` suite when a module requires targeted wiring and guardrail checks.

#### Scenario: Rocket.Chat static suite is available
- **WHEN** a contributor needs to validate only the Rocket.Chat module wiring
- **THEN** they can run a dedicated make target for Rocket.Chat smoke tests
- **AND** the target executes the Rocket.Chat module static checks without requiring a full runtime startup

### Requirement: Semaphore UI tests are included in the documented smoke test inventory
The system SHALL document Semaphore UI smoke test scripts in the standard `tests/README.md` inventory/table used by the repository.

#### Scenario: Semaphore UI inventory entry
- **WHEN** a contributor scans the smoke test inventory
- **THEN** Semaphore UI-specific smoke tests appear with purpose and prerequisites

### Requirement: Plane service receives service-scoped smoke coverage
The test suite SHALL include Plane-specific smoke tests for compose wiring, guardrails, Makefile targets, bootstrap behavior, and optional integration toggles.

#### Scenario: Plane smoke target execution
- **WHEN** a contributor runs `make test-plane`
- **THEN** Plane smoke tests execute without requiring unrelated module tests

#### Scenario: Service-aware healthcheck integration
- **WHEN** Plane services are running during `make test`
- **THEN** `scripts/healthcheck.sh` executes the Plane smoke suite according to service-aware test selection rules

### Requirement: FreeIPA smoke suite is part of documented service-aware testing
The system SHALL provide a FreeIPA smoke suite and document it in the smoke test inventory.

#### Scenario: Operator runs FreeIPA smoke suite
- **WHEN** an operator runs `make test-freeipa`
- **THEN** FreeIPA service configuration, make wiring, bootstrap idempotency, guardrails, and optional integration contracts are validated.

#### Scenario: Service-aware test runner detects FreeIPA
- **WHEN** FreeIPA container is running and `make test` executes `scripts/healthcheck.sh`
- **THEN** the FreeIPA smoke subset is executed as part of service-aware suites.

### Requirement: Advanced observability smoke coverage
The smoke test suite SHALL include static/no-sudo checks for advanced observability wiring and provisioning.

#### Scenario: Contributor runs observability smoke suite
- **WHEN** a contributor runs the observability smoke test set
- **THEN** tests verify Tempo/Pyroscope compose wiring and internal-only exposure defaults
- **AND** tests verify Alloy trace/profile pipeline presence
- **AND** tests verify Grafana datasource provisioning for Tempo/Pyroscope
- **AND** tests verify k6 target wiring and script availability

### Requirement: Docling service receives service-scoped smoke coverage
The test suite SHALL include Docling-specific smoke tests for compose wiring, guardrails, Makefile targets, bootstrap behavior, and optional integration toggles.

#### Scenario: Docling smoke target execution
- **WHEN** a contributor runs `make test-docling`
- **THEN** Docling smoke tests execute without requiring unrelated module tests

#### Scenario: Service-aware healthcheck integration
- **WHEN** Docling services are running during `make test`
- **THEN** `scripts/healthcheck.sh` executes the Docling smoke suite according to service-aware test selection rules

