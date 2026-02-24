## ADDED Requirements
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
