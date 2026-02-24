## ADDED Requirements
### Requirement: LiteLLM bootstrap secrets command
The system SHALL provide a bootstrap command to generate and populate required LiteLLM secrets in `.env`.

#### Scenario: Missing secrets are generated
- **WHEN** a user runs `make litellm-bootstrap` and LiteLLM secrets are missing in `.env`
- **THEN** the command writes generated values for the required LiteLLM secret variables

#### Scenario: Idempotent bootstrap by default
- **WHEN** a user runs `make litellm-bootstrap` and LiteLLM secrets already exist in `.env`
- **THEN** existing values are preserved by default
- **AND** the command reports that values were kept

#### Scenario: Explicit rotation supported
- **WHEN** a user requests a forced rotation (for example with a documented `--force` passthrough)
- **THEN** the bootstrap command overwrites existing LiteLLM secret values

#### Scenario: Custom env file supported
- **WHEN** a user runs the documented bootstrap workflow with a non-default env file path (for example via `ENV_FILE`)
- **THEN** LiteLLM secrets are written to that env file instead of requiring `.env`

### Requirement: LiteLLM env defaults in template
The project SHALL document LiteLLM environment variables in `.env.example`.

#### Scenario: LiteLLM env section discoverable
- **WHEN** a developer opens `.env.example`
- **THEN** a dedicated LiteLLM section lists image, hostname, and bootstrap-managed secret variables
- **AND** optional provider key variables are clearly labeled as optional
