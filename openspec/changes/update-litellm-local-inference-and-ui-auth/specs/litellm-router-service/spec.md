## MODIFIED Requirements
### Requirement: File-based LiteLLM proxy configuration
The system SHALL store LiteLLM proxy routing configuration as a repository-managed config file under `services/litellm/`.

#### Scenario: Config template present
- **WHEN** a developer enables the LiteLLM module
- **THEN** a committed config template file exists at `services/litellm/config.yaml`
- **AND** it contains documented model/provider examples aligned with the project `.env` strategy

#### Scenario: No secrets committed in config
- **WHEN** provider credentials or LiteLLM auth secrets are required
- **THEN** the config template references environment variables instead of embedding literal secrets

#### Scenario: Default local inference route
- **WHEN** a developer starts LiteLLM with default LiteLLM module settings
- **THEN** the config template includes a preconfigured local inference route driven by `.env` variables
- **AND** the route can be used without manually editing `services/litellm/config.yaml`

### Requirement: Optional LiteLLM router service profile
The system SHALL provide an optional `litellm` Compose profile with a LiteLLM proxy service exposed behind Traefik HTTPS.

#### Scenario: Traefik-only HTTPS exposure
- **WHEN** the `litellm` profile is enabled
- **THEN** LiteLLM is reachable through Traefik at `https://llm.${DEV_DOMAIN}` (or the configured hostname override)
- **AND** the LiteLLM HTTP API port is not published directly on the host by default

#### Scenario: TLS resolver compatibility
- **WHEN** the stack runs in TLS Mode A, B, or C
- **THEN** the LiteLLM Traefik router follows the shared `TLS_CERT_RESOLVER` pattern used by other services

## ADDED Requirements
### Requirement: Separate LiteLLM management UI router
The LiteLLM module SHALL expose a dedicated management hostname/router separate from the primary API hostname.

#### Scenario: API and management hostnames are distinct
- **WHEN** the LiteLLM module is enabled with default settings
- **THEN** the API hostname and management UI hostname use separate Traefik routers
- **AND** the management router points to the same LiteLLM backend service without changing the API hostname behavior

### Requirement: Management UI access protection
The LiteLLM management hostname SHALL be protected with project-standard UI access controls.

#### Scenario: Traefik BasicAuth on management router
- **WHEN** a user accesses the LiteLLM management hostname
- **THEN** a Traefik BasicAuth middleware is applied using a generated htpasswd file
- **AND** the primary API hostname is not forced to use the same BasicAuth middleware

### Requirement: Local inference host reachability defaults
The LiteLLM service SHALL support a default local inference backend endpoint that is reachable from the container in a standard Docker setup.

#### Scenario: Host-based local inference backend default
- **WHEN** the local inference backend default points to a host-local service (for example an Ollama-compatible endpoint)
- **THEN** the LiteLLM container compose configuration includes the required host reachability wiring (or documented equivalent) for Linux Docker compatibility

### Requirement: Standalone Traefik + LiteLLM deployment mode
The project SHALL support a standalone deployment mode that starts Traefik and LiteLLM without unrelated local service containers.

#### Scenario: Standalone mode service scope
- **WHEN** a user starts the documented standalone LiteLLM edge mode
- **THEN** the compose invocation starts `traefik` and `litellm`
- **AND** it does not require starting `whoami`, `dns`, or local `stepca` containers
