## MODIFIED Requirements
### Requirement: Smoke test inventory is presented as a standard table
The documentation for `make test` SHALL include a table that lists each smoke test script executed by `scripts/healthcheck.sh` and describes its purpose, prerequisites, and expected signal. The table SHALL cover all current scripts in `tests/smoke/` and provide a consistent, scan-friendly format.

#### Scenario: Contributor scans the test suite
- **WHEN** a contributor opens `tests/README.md` to understand `make test`
- **THEN** they see a table enumerating each smoke test script with its purpose, prerequisites, and expected output
- **AND** the list matches the scripts invoked by `scripts/healthcheck.sh`

#### Scenario: New service observability smoke strategy is explicit
- **WHEN** a new service adds optional observability wiring
- **THEN** the service's observability-related tests are classified as static smoke checks or manual runtime validation
- **AND** default `make test` behavior does not silently require the observability stack unless explicitly documented
