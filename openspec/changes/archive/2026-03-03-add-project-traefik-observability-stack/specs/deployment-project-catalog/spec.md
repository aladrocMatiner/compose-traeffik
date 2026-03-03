## ADDED Requirements

### Requirement: Project `traefik-observability` publishes web endpoints behind Traefik
The system SHALL publish observability web endpoints through Traefik reverse proxy in the `traefik-observability` project workflow.

#### Scenario: Operator selects `project=traefik-observability`
- **WHEN** an operator runs `make deployment-project project=traefik-observability`
- **THEN** runtime routing for observability web endpoints is exposed through Traefik-managed routes
- **AND** observability web services are not exposed as a direct bypass of the Traefik edge path

### Requirement: Project `traefik-observability` declares StepCA and Keycloak project dependencies
The system SHALL provide a predefined project `traefik-observability` whose manifest declares dependencies on `traefik-stepca` and `traefik-keycloak`.

#### Scenario: Observability project manifest is inspected
- **WHEN** an operator inspects the `traefik-observability` project definition
- **THEN** `depends_on_projects` includes `traefik-stepca` and `traefik-keycloak`
- **AND** dependency intent is explicit without relying on external documentation

### Requirement: Project `traefik-observability` defaults to StepCA ACME for certificates through Traefik TLS termination
The system SHALL default `traefik-observability` project TLS mode to StepCA-backed ACME unless an explicit supported override is provided, and TLS termination SHALL be handled by Traefik according to the selected OpenSpec TLS mode.

#### Scenario: Default TLS mode is applied
- **WHEN** `project=traefik-observability` is run without TLS override
- **THEN** runtime configuration uses StepCA ACME as certificate source
- **AND** Traefik certificate resolution uses StepCA ACME settings from project/environment contract
- **AND** compose deployment proceeds only when required StepCA ACME settings are available

#### Scenario: TLS override is provided
- **WHEN** an operator provides an explicit supported `tls_mode` override
- **THEN** the project uses the requested TLS mode instead of StepCA ACME default
- **AND** deployment validates mode-specific required variables before compose apply

### Requirement: Project `traefik-observability` enforces Keycloak-based authentication contract
The system SHALL configure observability endpoints to use Keycloak-based authentication as defined by the project manifest contract.

#### Scenario: Auth contract is applied
- **WHEN** `project=traefik-observability` is deployed with dependencies satisfied
- **THEN** runtime config applies Keycloak-backed authentication integration for observability access paths
- **AND** deployment fails fast if required Keycloak integration variables are missing

### Requirement: Project `traefik-observability` deploys only manifest-declared services
The system SHALL deploy only services declared by the `traefik-observability` project manifest and SHALL reject ad-hoc runtime service overrides.

#### Scenario: Runtime service override conflicts with project manifest
- **WHEN** runtime inputs attempt to deploy services outside the manifest service list
- **THEN** deployment fails with a contract-violation message
- **AND** `docker compose up -d` is not executed with conflicting service selection
