## ADDED Requirements
### Requirement: Optional LiteLLM router service profile
The system SHALL provide an optional `litellm` Compose profile with a LiteLLM proxy service exposed behind Traefik HTTPS.

#### Scenario: Traefik-only HTTPS exposure
- **WHEN** the `litellm` profile is enabled
- **THEN** LiteLLM is reachable through Traefik at `https://llm.${DEV_DOMAIN}` (or the configured hostname override)
- **AND** the LiteLLM HTTP API port is not published directly on the host by default

#### Scenario: TLS resolver compatibility
- **WHEN** the stack runs in TLS Mode A, B, or C
- **THEN** the LiteLLM Traefik router follows the shared `TLS_CERT_RESOLVER` pattern used by other services

### Requirement: Safe default Traefik middleware for LiteLLM
The LiteLLM Traefik router SHALL apply a safe default middleware set that includes the shared security headers middleware.

#### Scenario: Default middleware includes security headers
- **WHEN** a user enables the LiteLLM module with default settings
- **THEN** the LiteLLM Traefik router applies a middleware list that includes `security-headers@file`
- **AND** the middleware list is configurable through `.env`

### Requirement: File-based LiteLLM proxy configuration
The system SHALL store LiteLLM proxy routing configuration as a repository-managed config file under `services/litellm/`.

#### Scenario: Config template present
- **WHEN** a developer enables the LiteLLM module
- **THEN** a committed config template file exists at `services/litellm/config.yaml`
- **AND** it contains documented model/provider examples aligned with the project `.env` strategy

#### Scenario: No secrets committed in config
- **WHEN** provider credentials or LiteLLM auth secrets are required
- **THEN** the config template references environment variables instead of embedding literal secrets

### Requirement: LiteLLM authentication enabled by default
The system SHALL require LiteLLM API authentication in the module's default configuration.

#### Scenario: API key enforcement path documented
- **WHEN** a user reads the LiteLLM service documentation
- **THEN** it explains that requests must include the configured LiteLLM bearer/master key (or the upstream equivalent for the pinned version)

### Requirement: Auxiliary endpoint exposure policy is explicit
The LiteLLM module SHALL explicitly handle upstream docs/admin/auxiliary HTTP endpoints for the pinned version.

#### Scenario: Auxiliary endpoints are reviewed
- **WHEN** the module is implemented for a pinned LiteLLM version
- **THEN** any auxiliary endpoints exposed by default are either disabled or documented with security notes and authentication expectations

### Requirement: Minimal dependency footprint for v1
The initial LiteLLM module SHALL run without requiring Postgres or Redis profiles.

#### Scenario: LiteLLM profile startup scope
- **WHEN** a user starts the LiteLLM service with `make litellm-up`
- **THEN** only the LiteLLM service and required shared stack services are needed
- **AND** no new database/cache service is mandatory in this change

### Requirement: Pinned LiteLLM image version
The system SHALL pin the LiteLLM container image version in project configuration.

#### Scenario: Image pinning in env defaults
- **WHEN** a user inspects `.env.example`
- **THEN** the LiteLLM image variable is set to an explicit version tag rather than `latest`
