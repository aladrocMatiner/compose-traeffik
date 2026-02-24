## MODIFIED Requirements
### Requirement: LiteLLM profile preflight validation
The system SHALL validate LiteLLM-specific environment settings during preflight when the `litellm` profile is enabled.

#### Scenario: Missing LiteLLM secrets
- **WHEN** `COMPOSE_PROFILES` includes `litellm` and required LiteLLM secrets are unset
- **THEN** `scripts/validate-env.sh` fails with a clear message
- **AND** the message tells the user how to run `make litellm-bootstrap`

#### Scenario: Placeholder LiteLLM secrets
- **WHEN** `COMPOSE_PROFILES` includes `litellm` and LiteLLM secrets are blank or known placeholders
- **THEN** preflight validation fails before Docker Compose runs

#### Scenario: LiteLLM profile disabled
- **WHEN** `COMPOSE_PROFILES` does not include `litellm`
- **THEN** LiteLLM-specific missing secret checks do not fail preflight by themselves

#### Scenario: LiteLLM UI auth file missing
- **WHEN** the LiteLLM management router is enabled and the configured LiteLLM UI htpasswd file path is missing or points to an example file
- **THEN** preflight validation fails with a clear message describing how to generate the file via `make litellm-bootstrap`

### Requirement: LiteLLM hostname validation
The system SHALL validate the LiteLLM hostname prefix used for Traefik routing.

#### Scenario: Invalid hostname prefix
- **WHEN** `LITELLM_HOSTNAME` contains invalid hostname characters or formatting
- **THEN** preflight validation fails with a clear error

## ADDED Requirements
### Requirement: LiteLLM management hostname validation
The system SHALL validate the LiteLLM management UI hostname prefix used for Traefik routing.

#### Scenario: Invalid management hostname prefix
- **WHEN** `LITELLM_UI_HOSTNAME` contains invalid hostname characters or formatting
- **THEN** preflight validation fails with a clear error

### Requirement: Local inference endpoint env validation
The system SHALL validate LiteLLM local inference endpoint env formatting without requiring runtime connectivity.

#### Scenario: Malformed local inference endpoint
- **WHEN** the configured local inference base URL or host/port env values are malformed
- **THEN** preflight validation fails with a clear message

#### Scenario: Unreachable local inference endpoint not checked in preflight
- **WHEN** the local inference service is not running
- **THEN** preflight validation does not fail solely due to runtime connectivity
- **AND** documentation explains the difference between config validation and runtime availability
