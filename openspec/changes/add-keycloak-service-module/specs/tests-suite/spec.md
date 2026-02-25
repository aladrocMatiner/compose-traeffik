## MODIFIED Requirements
### Requirement: Smoke test inventory is presented as a standard table
The documentation for `make test` SHALL include a table that lists each smoke test script executed by `scripts/healthcheck.sh` and describes its purpose, prerequisites, and expected signal. The table SHALL cover all current scripts in `tests/smoke/` and provide a consistent, scan-friendly format.

#### Scenario: Contributor scans the test suite
- **WHEN** a contributor opens `tests/README.md` to understand `make test`
- **THEN** they see a table enumerating each smoke test script with its purpose, prerequisites, and expected output
- **AND** the list matches the scripts invoked by `scripts/healthcheck.sh`

#### Scenario: Keycloak service smoke coverage
- **WHEN** the Keycloak module is added
- **THEN** the repository includes service-specific smoke tests for Make wiring, compose/Traefik configuration, and guardrails
- **AND** any observability-related Keycloak test added in this change avoids requiring the observability stack runtime by default

#### Scenario: Keycloak test target exists
- **WHEN** the Keycloak module is added
- **THEN** a dedicated `make test-keycloak` target exists for Keycloak-specific smoke checks
- **AND** the target can be used independently of unrelated service runtime state
