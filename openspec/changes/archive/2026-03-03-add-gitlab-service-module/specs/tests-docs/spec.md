## MODIFIED Requirements

### Requirement: Smoke test documentation
The system SHALL document smoke tests in `tests/README.md` with purpose, run instructions, inventory, configuration, expected output, and troubleshooting. Service modules such as GitLab SHALL include module-specific smoke test entry points and prerequisites.

#### Scenario: Documentation completeness
- **WHEN** a user reads `tests/README.md`
- **THEN** they can understand what each test validates and how to interpret failures

#### Scenario: GitLab test entry points documented
- **WHEN** GitLab is available as a service module
- **THEN** `tests/README.md` documents `make test-gitlab`, required `.env` state, and any runtime test limitations
