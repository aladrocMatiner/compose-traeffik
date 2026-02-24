## ADDED Requirements
### Requirement: Service-scoped smoke test Make targets
The system SHALL provide dedicated Makefile smoke-test targets for the core stack and each optional service/module so contributors can run relevant checks without invoking unrelated suites.

#### Scenario: Run module-specific smoke tests
- **WHEN** a contributor runs `make test-dns`, `make test-ctfd`, or `make test-observability`
- **THEN** only the smoke tests assigned to that service/module suite are executed
- **AND** the command exits non-zero if any test in that suite fails

#### Scenario: Run core smoke tests
- **WHEN** a contributor runs `make test-core`
- **THEN** the command executes the core Traefik/whoami smoke tests
- **AND** it does not invoke DNS, CTFd, or observability module smoke suites

### Requirement: Adaptive `make test` smoke execution
The system SHALL keep `make test` as the default smoke-test entrypoint but execute service-specific suites only for services that are currently running.

#### Scenario: Optional module not running
- **WHEN** a user runs `make test` and an optional module service (for example `bind` or `ctfd`) is not running
- **THEN** the corresponding service smoke suite is skipped
- **AND** the output indicates that the suite was skipped

#### Scenario: Running services selected automatically
- **WHEN** a user runs `make test` with one or more supported services running
- **THEN** `make test` executes the smoke suites mapped to those running services plus common utility smoke tests
