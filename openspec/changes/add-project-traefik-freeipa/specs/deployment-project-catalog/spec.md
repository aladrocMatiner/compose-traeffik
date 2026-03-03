## ADDED Requirements

### Requirement: Project `traefik-freeipa` deploys FreeIPA behind Traefik
The system SHALL provide a predefined project `traefik-freeipa` that deploys FreeIPA behind Traefik through the deployment project workflow.

#### Scenario: Operator selects `project=traefik-freeipa`
- **WHEN** an operator runs `make deployment-project project=traefik-freeipa`
- **THEN** project deployment syncs the declared repository/ref on the target VM
- **AND** compose apply starts only the manifest-declared services
- **AND** runtime routing for FreeIPA is exposed through Traefik-managed routes

### Requirement: Project `traefik-freeipa` declares StepCA, Keycloak, and Observability dependencies
The system SHALL provide a predefined project `traefik-freeipa` whose manifest declares dependencies on `traefik-stepca`, `traefik-keycloak`, and `traefik-observability`.

#### Scenario: FreeIPA manifest contract is inspected
- **WHEN** an operator inspects the `traefik-freeipa` project definition
- **THEN** `depends_on_projects` includes `traefik-stepca`, `traefik-keycloak`, and `traefik-observability`
- **AND** dependency intent is explicit without relying on external documentation

### Requirement: Project `traefik-freeipa` defaults to StepCA ACME with explicit TLS override support
The system SHALL default `traefik-freeipa` project TLS mode to StepCA-backed ACME unless an explicit supported override is provided, and TLS termination SHALL be handled by Traefik according to the selected OpenSpec TLS mode.

#### Scenario: Default TLS mode is applied
- **WHEN** `project=traefik-freeipa` is run without explicit TLS override
- **THEN** runtime configuration uses `stepca-acme` as certificate source
- **AND** deployment proceeds only when required StepCA ACME settings are available

#### Scenario: TLS override is provided
- **WHEN** an operator provides an explicit supported `tls_mode` override
- **THEN** the project uses the requested TLS mode instead of the default
- **AND** deployment validates mode-specific required variables before compose apply

### Requirement: Project `traefik-freeipa` enforces Keycloak OIDC authentication contract
The system SHALL configure FreeIPA authentication integration with Keycloak according to the project manifest contract.

#### Scenario: OIDC contract is applied
- **WHEN** `project=traefik-freeipa` is deployed with dependencies satisfied
- **THEN** runtime config applies Keycloak-backed authentication integration for FreeIPA sign-in flow
- **AND** deployment fails fast if required Keycloak integration variables are missing

### Requirement: Project `traefik-freeipa` enforces observability integration contract
The system SHALL apply FreeIPA observability integration settings according to project contract and SHALL keep telemetry exposure aligned with repository observability guardrails.

#### Scenario: Observability contract is applied
- **WHEN** `project=traefik-freeipa` is deployed with `traefik-observability` dependency satisfied
- **THEN** runtime configuration applies the declared observability integration settings
- **AND** deployment fails fast when observability contract variables are required but missing

### Requirement: Project `traefik-freeipa` deploys only manifest-declared services
The system SHALL deploy only services declared by the `traefik-freeipa` manifest and SHALL reject ad-hoc runtime service overrides.

#### Scenario: Runtime service override conflicts with manifest
- **WHEN** runtime inputs attempt to deploy services outside the manifest service list
- **THEN** deployment fails with a contract-violation message
- **AND** `docker compose up -d` is not executed with conflicting service selection
