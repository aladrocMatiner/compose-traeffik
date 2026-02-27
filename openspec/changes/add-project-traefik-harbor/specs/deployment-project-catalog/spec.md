## ADDED Requirements

### Requirement: Project `traefik-harbor` deploys Harbor behind Traefik
The system SHALL publish Harbor through Traefik reverse proxy in the `traefik-harbor` project workflow.

#### Scenario: Operator selects `project=traefik-harbor`
- **WHEN** an operator runs `make deployment-project project=traefik-harbor`
- **THEN** runtime routing for Harbor is exposed through Traefik-managed routes
- **AND** Harbor is not exposed as a direct bypass of the Traefik edge path

### Requirement: Project `traefik-harbor` declares dependencies on StepCA and Keycloak projects
The system SHALL provide a predefined project `traefik-harbor` whose manifest declares dependencies on `traefik-stepca` and `traefik-keycloak`.

#### Scenario: Harbor project manifest is inspected
- **WHEN** an operator inspects the `traefik-harbor` project definition
- **THEN** `depends_on_projects` includes `traefik-stepca` and `traefik-keycloak`
- **AND** dependency intent is explicit without relying on external documentation

### Requirement: Project `traefik-harbor` defaults to StepCA ACME for certificates through Traefik TLS termination
The system SHALL default `traefik-harbor` project TLS mode to StepCA-backed ACME unless an explicit supported override is provided, and TLS termination SHALL be handled by Traefik according to the selected OpenSpec TLS mode.

#### Scenario: Default TLS mode is applied
- **WHEN** `project=traefik-harbor` is run without TLS override
- **THEN** runtime configuration uses StepCA ACME as certificate source
- **AND** Traefik certificate resolution uses StepCA ACME settings from project/environment contract
- **AND** deployment proceeds only when required StepCA ACME settings are available

#### Scenario: TLS override is provided
- **WHEN** an operator provides an explicit supported `tls_mode` override
- **THEN** the project uses the requested TLS mode instead of StepCA ACME default
- **AND** deployment validates mode-specific required variables before compose apply

### Requirement: Project `traefik-harbor` enforces Keycloak-based authentication contract
The system SHALL configure Harbor authentication integration with Keycloak according to the project manifest contract.

#### Scenario: Auth contract is applied
- **WHEN** `project=traefik-harbor` is deployed with dependencies satisfied
- **THEN** runtime config applies Keycloak-backed authentication for Harbor sign-in
- **AND** deployment fails fast if required Keycloak integration variables are missing

### Requirement: Project `traefik-harbor` defines observability integration contract compatible with `traefik-observability`
The system SHALL define an observability contract for `traefik-harbor` that is compatible with `traefik-observability`, and SHALL keep the base Harbor deployment operable without requiring `traefik-observability` as a hard dependency.

#### Scenario: Base deployment runs without observability dependency
- **WHEN** `project=traefik-harbor` is deployed with default observability settings
- **THEN** deployment is not blocked by absence of `traefik-observability` dependency
- **AND** project configuration preserves Harbor/Traefik telemetry hooks required for later observability integration

#### Scenario: Explicit observability integration is enabled
- **WHEN** operators enable the Harbor observability integration mode
- **THEN** deployment validates required observability variables before compose apply
- **AND** deployment fails fast with clear missing-variable messages when observability prerequisites are incomplete

### Requirement: Project `traefik-harbor` deploys only manifest-declared services
The system SHALL deploy only services declared by the `traefik-harbor` manifest and SHALL reject ad-hoc runtime service overrides.

#### Scenario: Runtime service override conflicts with manifest
- **WHEN** runtime inputs attempt to deploy services outside the manifest service list
- **THEN** deployment fails with a contract-violation message
- **AND** `docker compose up -d` is not executed with conflicting service selection
