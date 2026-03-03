## ADDED Requirements
### Requirement: Service-scoped test command documentation
The smoke test documentation SHALL describe service-scoped `make test-*` commands and explain the service-aware behavior of `make test`.

#### Scenario: Contributor chooses a targeted suite
- **WHEN** a contributor reads `tests/README.md` to run smoke tests for a specific module
- **THEN** the documentation lists the relevant `make test-*` commands
- **AND** indicates that `make test` auto-selects suites based on running services

#### Scenario: Contributor interprets skipped suites
- **WHEN** a contributor sees skipped suite messages during `make test`
- **THEN** `tests/README.md` explains that service-specific suites are skipped when their services are not running
