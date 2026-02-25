## MODIFIED Requirements
### Requirement: Smoke test inventory is presented as a standard table
The documentation for `make test` SHALL include a table that lists each smoke test script executed by `scripts/healthcheck.sh` and describes its purpose, prerequisites, and expected signal. The table SHALL cover all current scripts in `tests/smoke/` and provide a consistent, scan-friendly format. For heavy or hybrid modules whose runtime validation is not part of the default smoke path (for example AWX on k3d), the inventory SHALL clearly distinguish static smoke checks from manual runtime validation steps.

#### Scenario: Contributor scans the test suite
- **WHEN** a contributor opens `tests/README.md` to understand `make test`
- **THEN** they see a table enumerating each smoke test script with its purpose, prerequisites, and expected output
- **AND** the list matches the scripts invoked by `scripts/healthcheck.sh`

#### Scenario: AWX tests documented as static vs runtime
- **WHEN** AWX smoke tests are added for wiring/guardrails/templates
- **THEN** `tests/README.md` indicates which AWX checks are included in automated smoke runs and which validations require manual runtime execution on a local k3d cluster
