## MODIFIED Requirements
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

#### Scenario: Local inference default config validation
- **WHEN** LiteLLM smoke tests run after local inference defaults are added
- **THEN** they verify the presence of the default local inference route and container reachability wiring in config/compose files without requiring a live local inference service

#### Scenario: Management UI auth config validation
- **WHEN** LiteLLM smoke tests run after the management hostname/router is added
- **THEN** they verify the admin router labels, UI BasicAuth middleware wiring, bootstrap-generated UI credential behavior, and preflight validation for missing UI auth files

#### Scenario: Standalone mode wiring validation
- **WHEN** LiteLLM smoke tests run after standalone Traefik + LiteLLM mode is added
- **THEN** they verify standalone Make target/help wiring and the documented compose service-selection pattern for `traefik` + `litellm` without `whoami`
