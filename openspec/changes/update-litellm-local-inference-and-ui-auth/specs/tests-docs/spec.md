## MODIFIED Requirements
### Requirement: LiteLLM smoke test documentation
The test documentation SHALL describe LiteLLM smoke tests, what they validate, and their execution constraints.

#### Scenario: LiteLLM tests described in tests README
- **WHEN** a user reads `tests/README.md`
- **THEN** they can identify the LiteLLM smoke tests and understand that they do not require sudo or external LLM provider credentials

#### Scenario: Healthcheck coverage documented
- **WHEN** a user checks `tests/README.md`
- **THEN** the documentation explains that the LiteLLM smoke tests are part of the standard smoke suite (or explicitly notes exceptions)

#### Scenario: Local inference and UI auth test scope documented
- **WHEN** LiteLLM local inference defaults and management UI auth checks are added
- **THEN** `tests/README.md` explains that the tests validate config/bootstrap/guardrails only and not runtime connectivity to the local inference backend

#### Scenario: Standalone mode test scope documented
- **WHEN** standalone Traefik + LiteLLM mode tests are added
- **THEN** `tests/README.md` explains that standalone tests validate Make/config wiring and service selection, not full runtime certificate issuance against a remote `step-ca`
