## ADDED Requirements

### Requirement: Scripts docs include observability-related service scripts and toggles
The system SHALL document observability-related service scripts or bootstrap toggles in `scripts/README.md` when a service introduces them.

#### Scenario: Observability bootstrap or render helper added
- **WHEN** a service adds scripts or documented workflows related to observability wiring
- **THEN** `scripts/README.md` describes the scripts and the relevant toggles/side effects
