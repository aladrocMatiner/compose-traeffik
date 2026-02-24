## ADDED Requirements
### Requirement: LiteLLM profile preflight validation
The system SHALL validate LiteLLM-specific environment settings during preflight when the `litellm` profile is enabled.

#### Scenario: Missing LiteLLM secrets
- **WHEN** `COMPOSE_PROFILES` includes `litellm` and required LiteLLM secrets are unset
- **THEN** `scripts/validate-env.sh` fails with a clear message
- **AND** the message tells the user how to run `make litellm-bootstrap`

#### Scenario: LiteLLM profile disabled
- **WHEN** `COMPOSE_PROFILES` does not include `litellm`
- **THEN** LiteLLM-specific missing secret checks do not fail preflight by themselves

#### Scenario: Placeholder LiteLLM secrets
- **WHEN** `COMPOSE_PROFILES` includes `litellm` and LiteLLM secrets are blank or known placeholders
- **THEN** preflight validation fails before Docker Compose runs

### Requirement: LiteLLM hostname validation
The system SHALL validate the LiteLLM hostname prefix used for Traefik routing.

#### Scenario: Invalid hostname prefix
- **WHEN** `LITELLM_HOSTNAME` contains invalid hostname characters or formatting
- **THEN** preflight validation fails with a clear error

### Requirement: Provider-key-optional preflight behavior
The system SHALL allow preflight to pass without provider API keys so the module can be scaffolded and tested locally without external dependencies.

#### Scenario: No provider credentials configured
- **WHEN** the `litellm` profile is enabled and optional provider key variables are empty
- **THEN** preflight does not fail solely because provider credentials are missing
- **AND** documentation explains that proxy requests will fail until a provider is configured
