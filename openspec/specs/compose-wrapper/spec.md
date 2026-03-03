# compose-wrapper Specification

## Purpose
TBD - created by archiving change fix-compose-project-pin. Update Purpose after archive.
## Requirements
### Requirement: Deterministic compose project
The system SHALL pin the compose project name and project directory so that commands run from any CWD reuse the same project, networks, and volumes.

#### Scenario: Different CWD
- **WHEN** a compose command is run from a different working directory
- **THEN** the same compose project name and resources are used

### Requirement: Functional ps target
The system SHALL provide working service lifecycle and test targets that use the standard compose wrapper, including service-specific targets for modular services such as GitLab.

#### Scenario: make ps
- **WHEN** a user runs `make ps`
- **THEN** the command executes successfully and lists services

#### Scenario: GitLab lifecycle and test targets
- **WHEN** a user runs `make gitlab-up`, `make gitlab-down`, `make gitlab-logs`, `make gitlab-status`, or `make test-gitlab`
- **THEN** the target executes successfully using the standard compose wrapper and repository test runner conventions
- **AND** `make help` documents the target names and purpose

### Requirement: BIND lifecycle targets use deterministic compose wrapper
The system SHALL execute BIND lifecycle Make targets through the shared compose wrapper so project name and project directory remain deterministic regardless of current working directory.

#### Scenario: Operator runs command from alternate directory
- **WHEN** an operator executes `make bind-up` (or any BIND lifecycle target) from any CWD using the project Makefile
- **THEN** the command uses the pinned compose project settings
- **AND** reuses the expected project networks and volumes

#### Scenario: Profile and service scope are explicit
- **WHEN** a BIND lifecycle target is executed
- **THEN** compose is invoked with profile `bind`
- **AND** the target is scoped to BIND operations rather than unrelated services

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

### Requirement: Semaphore UI lifecycle targets use the compose wrapper pattern
The system SHALL provide Semaphore UI lifecycle Make targets that invoke the standard compose wrapper with the `semaphoreui` profile.

#### Scenario: Semaphore UI lifecycle command
- **WHEN** a user runs `make semaphoreui-up` (or related lifecycle targets)
- **THEN** the command executes through `scripts/compose.sh`
- **AND** the `semaphoreui` profile is enabled for the compose invocation

### Requirement: Semaphore UI service-specific smoke test target
The system SHALL provide a dedicated `make test-semaphoreui` target for Semaphore UI static smoke tests.

#### Scenario: Service-specific test invocation
- **WHEN** a user runs `make test-semaphoreui`
- **THEN** only Semaphore UI service smoke tests are executed
- **AND** the command does not require the Semaphore UI runtime stack to be running

### Requirement: Semaphore UI smoke tests integrate with the repository test runner conventions
The system SHALL integrate Semaphore UI smoke tests with the repository's standard `make test`/`scripts/healthcheck.sh` conventions used by the current branch.

#### Scenario: Branch-level smoke test runner includes Semaphore UI checks
- **WHEN** a contributor runs the branch-standard smoke test runner (`make test` or equivalent wrapper)
- **THEN** Semaphore UI smoke tests are included according to the branch's documented test-runner behavior
- **AND** the test documentation inventory matches the implemented wiring

### Requirement: Plane module lifecycle targets use the shared compose wrapper
The system SHALL provide Plane module lifecycle targets that use `scripts/compose.sh` and the `plane` profile, preserving deterministic compose project behavior.

#### Scenario: Plane lifecycle commands
- **WHEN** a user runs `make plane-up`, `make plane-down`, or `make plane-status`
- **THEN** commands execute through the shared compose wrapper with `--profile plane`
- **AND** they operate only on Plane module services

#### Scenario: Plane smoke target
- **WHEN** a user runs `make test-plane`
- **THEN** only Plane-specific smoke tests are executed using the repository test wrappers

### Requirement: Observability lifecycle targets include advanced signal services
The system SHALL provide Makefile wrappers for advanced observability lifecycle commands through `scripts/compose.sh` while preserving deterministic compose project behavior.

#### Scenario: Observability lifecycle with advanced services
- **WHEN** a user runs observability lifecycle targets (up, down, restart, logs, status)
- **THEN** Tempo and Pyroscope are managed together with existing observability services through `scripts/compose.sh --profile observability`
- **AND** commands reuse the same compose project identity across working directories

#### Scenario: Synthetic check target uses repository wrappers
- **WHEN** a user runs the k6 synthetic check Make target
- **THEN** execution uses repository wrapper conventions (env loading, profile handling, and compose wiring) without ad-hoc local commands

### Requirement: Observability module Makefile wrappers
The system SHALL provide module-scoped Makefile targets for the observability stack that invoke the shared compose wrapper and preserve deterministic compose project behavior.

#### Scenario: Observability up/down/status
- **WHEN** a user runs `make observability-up`, `make observability-down`, or `make observability-status`
- **THEN** the commands use `scripts/compose.sh` with the `observability` profile
- **AND** they operate on the observability services without requiring manual compose flags

### Requirement: Docling module lifecycle targets use the shared compose wrapper
The system SHALL provide Docling module lifecycle targets that use `scripts/compose.sh` and the `docling` profile, preserving deterministic compose project behavior.

#### Scenario: Docling lifecycle commands
- **WHEN** a user runs `make docling-up`, `make docling-down`, or `make docling-status`
- **THEN** commands execute through the shared compose wrapper with `--profile docling`
- **AND** they operate only on Docling module services

#### Scenario: Docling smoke target
- **WHEN** a user runs `make test-docling`
- **THEN** only Docling-specific smoke tests are executed using repository test wrappers

### Requirement: CTFd module Makefile wrappers
The system SHALL provide module-scoped Makefile targets for CTFd that invoke the shared compose wrapper and preserve deterministic compose project behavior.

#### Scenario: CTFd up/down/status
- **WHEN** a user runs `make ctfd-up`, `make ctfd-down`, or `make ctfd-status`
- **THEN** the commands use `scripts/compose.sh` with the `ctfd` profile
- **AND** they operate on the CTFd module services without requiring the user to handcraft compose flags

