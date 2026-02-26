## ADDED Requirements

### Requirement: Wiki.js service layout follows service module conventions
The system SHALL place the Wiki.js module under `services/wikijs/` with a compose file and multilingual service documentation.

#### Scenario: Contributor inspects the Wiki.js service directory
- **WHEN** a contributor opens `services/wikijs/`
- **THEN** the directory contains `compose.yml`, `README.md`, `README.sv.md`, and `README.es.md`
- **AND** generated bootstrap artifacts are kept in a dedicated gitignored `rendered/` subdirectory
