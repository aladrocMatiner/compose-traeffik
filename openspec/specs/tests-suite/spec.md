# tests-suite Specification

## Purpose
TBD - created by archiving change document-make-test-suite-table. Update Purpose after archive.
## Requirements
### Requirement: Smoke test inventory is presented as a standard table
The documentation for `make test` SHALL include a table that lists each smoke test script executed by `scripts/healthcheck.sh` and describes its purpose, prerequisites, and expected signal. The table SHALL cover all current scripts in `tests/smoke/` and include observability wiring tests for new services when those tests exist.

#### Scenario: Contributor scans the test suite
- **WHEN** a contributor opens `tests/README.md` to understand `make test`
- **THEN** they see a table enumerating each smoke test script with its purpose, prerequisites, and expected output
- **AND** the list matches the scripts invoked by `scripts/healthcheck.sh`

#### Scenario: New service observability tests included
- **WHEN** a new service adds observability wiring smoke tests
- **THEN** the smoke test inventory table includes those tests and describes the secure-default behavior being validated
