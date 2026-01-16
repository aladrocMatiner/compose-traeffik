## ADDED Requirements
### Requirement: Smoke test documentation
The system SHALL document smoke tests in `tests/README.md` with purpose, run instructions, inventory, configuration, expected output, and troubleshooting.

#### Scenario: Documentation completeness
- **WHEN** a user reads `tests/README.md`
- **THEN** they can understand what each test validates and how to interpret failures

### Requirement: README link to tests
The system SHALL link to `tests/README.md` from the root README.

#### Scenario: Discoverability
- **WHEN** a user reads the root README
- **THEN** they can find a direct link to the smoke test documentation
