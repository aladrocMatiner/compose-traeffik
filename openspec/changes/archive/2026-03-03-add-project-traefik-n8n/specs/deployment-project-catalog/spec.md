## ADDED Requirements

### Requirement: Project `traefik-n8n` deploys n8n behind Traefik
The system SHALL provide a predefined project `traefik-n8n` that deploys n8n behind Traefik through the project deployment workflow.

#### Scenario: Operator selects `project=traefik-n8n`
- **WHEN** an operator runs `make deployment-project project=traefik-n8n`
- **THEN** project deployment syncs the declared repository/ref on the target VM
- **AND** compose apply starts the manifest-declared services for Traefik and n8n
- **AND** runtime routing for n8n is exposed through Traefik-managed routes

### Requirement: Project `traefik-n8n` defaults to StepCA ACME through Traefik TLS termination
The system SHALL default `traefik-n8n` TLS mode to StepCA-backed ACME unless an explicit supported override is provided, and TLS termination SHALL be handled by Traefik according to the selected OpenSpec TLS mode.

#### Scenario: Default TLS mode is applied
- **WHEN** `project=traefik-n8n` is run without TLS override
- **THEN** Traefik certificate handling for n8n routes uses `stepca-acme`
- **AND** deployment proceeds only when required StepCA ACME settings are available

#### Scenario: TLS override is provided
- **WHEN** an operator provides an explicit supported `tls_mode` override
- **THEN** Traefik uses the requested TLS mode for n8n routes
- **AND** deployment validates mode-specific required variables before compose apply

### Requirement: Project `traefik-n8n` supports optional Keycloak OIDC contract
The system SHALL support optional Keycloak OIDC integration for `traefik-n8n` when explicitly enabled by project configuration.

#### Scenario: OIDC mode is enabled
- **WHEN** OIDC integration is enabled for `traefik-n8n`
- **THEN** deployment validates required Keycloak OIDC variables before compose apply
- **AND** deployment fails fast with a clear missing-variable message when prerequisites are incomplete

### Requirement: Project `traefik-n8n` deploys only manifest-declared services
The system SHALL deploy only services declared by the `traefik-n8n` manifest and SHALL reject ad-hoc runtime service overrides.

#### Scenario: Runtime service override conflicts with manifest
- **WHEN** runtime inputs attempt to deploy services outside the manifest service list
- **THEN** deployment fails with a contract-violation message
- **AND** `docker compose up -d` is not executed with conflicting service selection
