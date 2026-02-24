# tests-docs Specification

## Purpose
TBD - created by archiving change docs-smoke-tests. Update Purpose after archive.
## Requirements
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

### Requirement: LiteLLM smoke test documentation
The test documentation SHALL describe LiteLLM smoke tests, what they validate, and their execution constraints.

#### Scenario: LiteLLM tests described in tests README
- **WHEN** a user reads `tests/README.md`
- **THEN** they can identify the LiteLLM smoke tests and understand that they do not require sudo or external LLM provider credentials

### Requirement: Healthcheck coverage documented
The test documentation SHALL state whether the LiteLLM smoke tests run through `make test` / `scripts/healthcheck.sh`.

#### Scenario: Discoverability of test runner integration
- **WHEN** a user checks `tests/README.md`
- **THEN** the documentation explains that the LiteLLM smoke tests are part of the standard smoke suite (or explicitly notes exceptions)

