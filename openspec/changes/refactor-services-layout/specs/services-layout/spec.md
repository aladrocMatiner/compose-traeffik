## ADDED Requirements
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
