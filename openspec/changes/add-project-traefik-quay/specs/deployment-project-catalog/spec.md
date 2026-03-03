## ADDED Requirements

### Requirement: Project `traefik-quay` deploys Quay behind Traefik
The system SHALL publish Quay through Traefik reverse proxy in the `traefik-quay` project workflow.

#### Scenario: Operator selects `project=traefik-quay`
- **WHEN** an operator runs `make deployment-project project=traefik-quay`
- **THEN** runtime routing for Quay is exposed through Traefik-managed routes
- **AND** Quay is not exposed as a direct bypass of the Traefik edge path

### Requirement: Project `traefik-quay` supports optional StepCA integration for certificates
The system SHALL support an optional StepCA integration mode for `traefik-quay` that uses Traefik TLS mode `stepca-acme` when explicitly enabled.

#### Scenario: Optional StepCA integration is enabled
- **WHEN** `traefik-quay` is configured with StepCA integration enabled
- **THEN** deployment sets TLS mode to `stepca-acme`
- **AND** deployment validates StepCA-specific required variables before compose apply
- **AND** deployment fails fast with a clear missing-variable message if StepCA prerequisites are incomplete

#### Scenario: Optional StepCA integration is disabled
- **WHEN** `traefik-quay` is deployed without StepCA integration enabled
- **THEN** deployment does not require StepCA-specific variables
- **AND** deployment uses the manifest-selected non-StepCA TLS mode

### Requirement: Project `traefik-quay` supports optional Keycloak authentication integration
The system SHALL support optional Keycloak OIDC/SSO integration for Quay when explicitly enabled by project configuration.

#### Scenario: Optional Keycloak integration is enabled
- **WHEN** `traefik-quay` enables Keycloak integration
- **THEN** deployment validates Keycloak integration variables before compose apply
- **AND** runtime configuration applies Keycloak-backed authentication for Quay sign-in

#### Scenario: Optional Keycloak integration is disabled
- **WHEN** `traefik-quay` is deployed without Keycloak integration enabled
- **THEN** deployment does not require Keycloak integration variables
- **AND** deployment proceeds with the base Quay auth contract defined by project defaults

### Requirement: Project `traefik-quay` supports optional observability integration
The system SHALL support optional observability integration for Quay and Traefik telemetry when explicitly enabled by project configuration.

#### Scenario: Optional observability integration is enabled
- **WHEN** `traefik-quay` enables observability integration
- **THEN** deployment validates required observability variables before compose apply
- **AND** runtime configuration enables the manifest-declared telemetry wiring for Quay and Traefik

#### Scenario: Optional observability integration is disabled
- **WHEN** `traefik-quay` is deployed without observability integration enabled
- **THEN** deployment does not require observability-specific variables
- **AND** deployment proceeds without blocking on observability dependencies

### Requirement: Project `traefik-quay` deploys only manifest-declared services
The system SHALL deploy only services declared by the `traefik-quay` manifest and SHALL reject ad-hoc runtime service overrides.

#### Scenario: Runtime service override conflicts with manifest
- **WHEN** runtime inputs attempt to deploy services outside the manifest service list
- **THEN** deployment fails with a contract-violation message
- **AND** `docker compose up -d` is not executed with conflicting service selection
