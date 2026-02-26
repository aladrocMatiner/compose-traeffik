## ADDED Requirements

### Requirement: Rocket.Chat service layout follows service module conventions
The system SHALL place the Rocket.Chat module under `services/rocketchat/` with a compose file and multilingual service documentation.

#### Scenario: Contributor inspects Rocket.Chat service directory
- **WHEN** a contributor opens `services/rocketchat/`
- **THEN** the directory contains `compose.yml`, `README.md`, `README.sv.md`, and `README.es.md`
- **AND** any generated bootstrap artifacts are kept in a dedicated gitignored `rendered/` subdirectory
