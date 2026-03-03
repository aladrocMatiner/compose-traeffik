## ADDED Requirements

### Requirement: FreeIPA service module exists under services/
The system SHALL provide a dedicated FreeIPA service module under `services/freeipa/` with compose and multilingual README files.

#### Scenario: Operator inspects service layout
- **WHEN** an operator inspects `services/freeipa/`
- **THEN** `compose.yml` exists
- **AND** `README.md`, `README.es.md`, and `README.sv.md` exist
- **AND** the module is integrated in compose layering via `Makefile`.
