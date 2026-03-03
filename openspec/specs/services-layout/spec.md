# services-layout Specification

## Purpose
TBD - created by archiving change refactor-services-layout. Update Purpose after archive.
## Requirements
### Requirement: Service layout under services/
The system SHALL organize each service under `services/<service>/` with a per-service compose file and README.

#### Scenario: Service composition
- **WHEN** a user inspects `services/<service>/`
- **THEN** it contains `compose.yml` and a `README.md` describing that service

### Requirement: Compose layering preserves workflows
The system SHALL preserve existing Makefile workflows by composing the same services and profiles using a documented compose layering strategy.

#### Scenario: Make targets remain valid
- **WHEN** a user runs `make up`, `make down`, `make logs`, or `make test`
- **THEN** behavior matches the pre-refactor stack behavior

### Requirement: Migration guidance
The system SHALL provide a migration note detailing what moved and how to update custom overrides.

#### Scenario: Migration instructions
- **WHEN** a user upgrades
- **THEN** they can update any custom compose overrides or mounts using the provided mapping

### Requirement: Rocket.Chat service layout follows service module conventions
The system SHALL place the Rocket.Chat module under `services/rocketchat/` with a compose file and multilingual service documentation.

#### Scenario: Contributor inspects Rocket.Chat service directory
- **WHEN** a contributor opens `services/rocketchat/`
- **THEN** the directory contains `compose.yml`, `README.md`, `README.sv.md`, and `README.es.md`
- **AND** any generated bootstrap artifacts are kept in a dedicated gitignored `rendered/` subdirectory

### Requirement: FreeIPA service module exists under services/
The system SHALL provide a dedicated FreeIPA service module under `services/freeipa/` with compose and multilingual README files.

#### Scenario: Operator inspects service layout
- **WHEN** an operator inspects `services/freeipa/`
- **THEN** `compose.yml` exists
- **AND** `README.md`, `README.es.md`, and `README.sv.md` exist
- **AND** the module is integrated in compose layering via `Makefile`.

