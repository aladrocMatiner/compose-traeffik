# tests-suite Specification

## Purpose
TBD - created by archiving change document-make-test-suite-table. Update Purpose after archive.
## Requirements
### Requirement: Smoke test inventory is presented as a standard table
The documentation for `make test` SHALL include a table that lists each smoke test script executed by `scripts/healthcheck.sh` and describes its purpose, prerequisites, and expected signal. The table SHALL cover all current scripts in `tests/smoke/`, including BIND-focused smoke checks, and provide a consistent, scan-friendly format.

#### Scenario: Contributor scans the test suite
- **WHEN** a contributor opens `tests/README.md` to understand `make test`
- **THEN** they see a table enumerating each smoke test script with its purpose, prerequisites, and expected output
- **AND** the list matches the scripts invoked by `scripts/healthcheck.sh`

#### Scenario: BIND checks are represented
- **WHEN** BIND-specific smoke checks are part of the suite
- **THEN** the inventory table explicitly lists them with prerequisites and expected signals
- **AND** the descriptions distinguish static config checks from runtime/behavior checks

### Requirement: DNS security smoke coverage
The system SHALL include DNS security smoke tests that verify recursion denial, AXFR denial, metadata minimization, provisioning-input validation, and listener-scope behavior.

#### Scenario: Security checks execute in smoke suite
- **WHEN** `make test` runs
- **THEN** DNS security smoke tests execute as part of `scripts/healthcheck.sh`
- **AND** failures are reported with explicit per-test signals

