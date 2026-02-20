## ADDED Requirements
### Requirement: Production-minimal bootstrap mode
The system SHALL provide a production-minimal bootstrap mode that generates `.env` with only the required endpoints and profiles needed to run the core stack in a production-style configuration.

#### Scenario: Minimal bootstrap
- **WHEN** a user runs `make bootstrap`
- **THEN** the generated `.env` enables only the production-minimal profiles/endpoints
- **AND** optional profiles remain disabled unless explicitly selected

### Requirement: Full bootstrap mode
The system SHALL provide a full bootstrap mode that preserves the current all-options defaults and is accessible via a dedicated command.

#### Scenario: Full bootstrap
- **WHEN** a user runs `make bootstrap-full`
- **THEN** the generated `.env` matches the current full-default behavior

## MODIFIED Requirements
### Requirement: Quickstart documentation
The quickstart in all README languages SHALL document both bootstrap modes and indicate which one is the default.

#### Scenario: Quickstart options
- **WHEN** a user reads the quickstart
- **THEN** they see `make bootstrap` (production-minimal) and `make bootstrap-full` (full)
