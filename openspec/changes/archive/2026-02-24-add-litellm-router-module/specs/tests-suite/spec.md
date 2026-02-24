## ADDED Requirements
### Requirement: LiteLLM no-sudo smoke tests
The system SHALL include no-sudo smoke tests that validate LiteLLM module wiring without requiring live provider calls.

#### Scenario: Compose and Traefik config validation
- **WHEN** LiteLLM smoke tests run
- **THEN** they verify the LiteLLM compose profile, service name, Traefik labels (including default middleware expectations), and no direct host port publish expectations

#### Scenario: Bootstrap and guardrail validation
- **WHEN** LiteLLM smoke tests run
- **THEN** they verify bootstrap `.env` generation/idempotency and LiteLLM preflight guardrails

#### Scenario: Config template validation
- **WHEN** LiteLLM smoke tests run
- **THEN** they verify the committed LiteLLM config template structure and environment-placeholder strategy

### Requirement: Make target verification tests
The system SHALL test that LiteLLM Make targets and help text are wired consistently with project conventions.

#### Scenario: Make target wiring
- **WHEN** the LiteLLM Make wiring test runs
- **THEN** it confirms `litellm-bootstrap` and `litellm-*` lifecycle targets exist and reference the standard compose wrapper/profile pattern

### Requirement: Healthcheck integration for LiteLLM smoke tests
The standard smoke test runner SHALL execute LiteLLM smoke tests.

#### Scenario: scripts/healthcheck includes LiteLLM tests
- **WHEN** `make test` runs
- **THEN** `scripts/healthcheck.sh` invokes the LiteLLM smoke tests as part of the smoke suite
