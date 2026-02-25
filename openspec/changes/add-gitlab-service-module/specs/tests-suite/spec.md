## MODIFIED Requirements

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
