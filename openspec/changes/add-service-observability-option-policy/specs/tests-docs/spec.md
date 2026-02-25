## MODIFIED Requirements

### Requirement: Smoke test documentation
The system SHALL document smoke tests in `tests/README.md` with purpose, run instructions, inventory, configuration, expected output, and troubleshooting. For new services with observability options, the documentation SHALL include the observability wiring smoke tests and note the default exposure posture they validate.

#### Scenario: Documentation completeness
- **WHEN** a user reads `tests/README.md`
- **THEN** they can understand what each test validates and how to interpret failures

#### Scenario: Observability wiring tests documented
- **WHEN** a new service adds observability hooks
- **THEN** `tests/README.md` documents the observability wiring smoke tests and the expected secure default behavior
