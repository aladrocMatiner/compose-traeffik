# tests-suite Specification

## Purpose
TBD - created by archiving change document-make-test-suite-table. Update Purpose after archive.
## Requirements
### Requirement: Smoke test inventory is presented as a standard table
The documentation for `make test` SHALL include a table that lists each smoke test script executed by `scripts/healthcheck.sh` and describes its purpose, prerequisites, and expected signal. The table SHALL cover all current scripts in `tests/smoke/` and provide a consistent, scan-friendly format.

#### Scenario: Contributor scans the test suite
- **WHEN** a contributor opens `tests/README.md` to understand `make test`
- **THEN** they see a table enumerating each smoke test script with its purpose, prerequisites, and expected output
- **AND** the list matches the scripts invoked by `scripts/healthcheck.sh`

### Requirement: Semaphore UI tests are included in the documented smoke test inventory
The system SHALL document Semaphore UI smoke test scripts in the standard `tests/README.md` inventory/table used by the repository.

#### Scenario: Semaphore UI inventory entry
- **WHEN** a contributor scans the smoke test inventory
- **THEN** Semaphore UI-specific smoke tests appear with purpose and prerequisites

### Requirement: Smoke test inventory covers service observability wiring checks
The standard smoke test inventory SHALL include observability wiring smoke tests for services that introduce observability toggles or labels.

#### Scenario: Contributor reviews service observability tests
- **WHEN** a contributor scans the smoke test inventory table
- **THEN** they can see which scripts validate observability wiring for each applicable service

