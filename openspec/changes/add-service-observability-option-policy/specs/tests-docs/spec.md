## ADDED Requirements

### Requirement: Test docs include observability wiring guidance for service modules
The system SHALL document service-specific observability smoke tests and expected signals in `tests/README.md` when a service exposes observability configuration.

#### Scenario: Service observability smoke tests exist
- **WHEN** a service adds observability wiring smoke tests
- **THEN** `tests/README.md` lists them with purpose and common failure interpretation
