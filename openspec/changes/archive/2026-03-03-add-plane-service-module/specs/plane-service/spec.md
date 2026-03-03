## ADDED Requirements
### Requirement: Optional Plane service module behind Traefik
The system SHALL provide an optional Plane module under `services/plane/` that runs behind Traefik using the repository's standard HTTP/HTTPS routing conventions.

#### Scenario: Plane profile enabled
- **WHEN** the `plane` profile is enabled and the module is started
- **THEN** Plane services are deployed with repository-managed configuration and persistence
- **AND** the Plane UI is reachable through Traefik at `https://plane.<DEV_DOMAIN>`

#### Scenario: Plane profile disabled
- **WHEN** the `plane` profile is not enabled
- **THEN** base stack behavior remains unchanged
- **AND** no Plane containers are started

### Requirement: Plane stateful dependencies are private and persistent by default
The Plane module SHALL run required stateful dependencies with internal networking and persistent volumes suitable for local and small self-hosted usage.

#### Scenario: Internal-only dependencies
- **WHEN** a user inspects the Plane compose module
- **THEN** Plane stateful dependencies are not publicly exposed by default
- **AND** Plane services reach them over internal Docker networks

#### Scenario: Persistent state survives recreation
- **WHEN** Plane containers are recreated
- **THEN** configured named volumes preserve application and dependency state according to module design

### Requirement: Plane TLS behavior stays compatible with existing modes including optional Step-CA
The Plane HTTPS router SHALL follow the existing `TLS_CERT_RESOLVER` contract so Plane works with Mode A, Mode B, and Mode C without service-specific TLS logic.

#### Scenario: Mode C with Step-CA enabled
- **WHEN** operators use Mode C (`stepca` profile and Step-CA resolver)
- **THEN** Plane HTTPS routing uses the same resolver contract as other Traefik-routed services

#### Scenario: Step-CA disabled
- **WHEN** operators run Plane without the `stepca` profile
- **THEN** Plane remains deployable using the current non-Step-CA TLS modes

### Requirement: Plane Keycloak integration is optional and opt-in
The system SHALL support optional Keycloak OIDC integration for Plane without making Keycloak a mandatory dependency for base Plane deployment.

#### Scenario: Keycloak integration disabled
- **WHEN** Plane runs with OIDC/Keycloak integration disabled
- **THEN** Plane remains functional with its default authentication path
- **AND** no Keycloak-specific runtime dependency is required

#### Scenario: Keycloak integration enabled
- **WHEN** operators enable Plane OIDC integration and provide required Keycloak settings
- **THEN** Plane consumes the configured OIDC settings
- **AND** the integration contract supports either a local Keycloak module or an external Keycloak endpoint

### Requirement: Plane observability integration is optional and safe by default
The system SHALL provide optional observability hooks for Plane that can integrate with the repository observability stack without creating public telemetry exposure by default.

#### Scenario: Observability disabled
- **WHEN** Plane runs without observability integration enabled
- **THEN** Plane startup and operation do not require observability services

#### Scenario: Observability enabled
- **WHEN** operators enable observability integration for Plane
- **THEN** Plane exposes documented telemetry hooks compatible with the repository observability pattern
- **AND** telemetry interfaces remain non-public by default unless explicitly configured otherwise
