## ADDED Requirements
### Requirement: Optional Docling service module behind Traefik
The system SHALL provide an optional Docling module under `services/docling/` that runs behind Traefik using the repository's standard HTTP/HTTPS routing conventions.

#### Scenario: Docling profile enabled
- **WHEN** the `docling` profile is enabled and the module is started
- **THEN** Docling services are deployed with repository-managed configuration and persistence
- **AND** the Docling API/UI is reachable through Traefik at `https://docling.<DEV_DOMAIN>`

#### Scenario: Docling profile disabled
- **WHEN** the `docling` profile is not enabled
- **THEN** base stack behavior remains unchanged
- **AND** no Docling containers are started

### Requirement: Docling stateful dependencies are private and persistent by default
The Docling module SHALL run required stateful dependencies with internal networking and persistent volumes suitable for local and small self-hosted usage.

#### Scenario: Internal-only dependencies
- **WHEN** a user inspects the Docling compose module
- **THEN** Docling stateful dependencies are not publicly exposed by default
- **AND** Docling services reach them over internal Docker networks

#### Scenario: Persistent state survives recreation
- **WHEN** Docling containers are recreated
- **THEN** configured volumes preserve model/artifact/cache state according to module design

### Requirement: Docling TLS behavior stays compatible with existing modes including optional Step-CA
The Docling HTTPS router SHALL follow the existing `TLS_CERT_RESOLVER` contract so Docling works with Mode A, Mode B, and Mode C without service-specific TLS logic.

#### Scenario: Mode C with Step-CA enabled
- **WHEN** operators use Mode C (`stepca` profile and Step-CA resolver)
- **THEN** Docling HTTPS routing uses the same resolver contract as other Traefik-routed services

#### Scenario: Step-CA disabled
- **WHEN** operators run Docling without the `stepca` profile
- **THEN** Docling remains deployable using current non-Step-CA TLS modes

### Requirement: Docling Keycloak integration is optional and opt-in
The system SHALL support optional Keycloak-based authentication integration for Docling without making Keycloak a mandatory dependency for baseline Docling deployment.

#### Scenario: Keycloak integration disabled
- **WHEN** Docling runs with Keycloak integration disabled
- **THEN** Docling remains functional with baseline auth settings (e.g., API key/open mode per operator choice)
- **AND** no Keycloak-specific runtime dependency is required

#### Scenario: Keycloak integration enabled
- **WHEN** operators enable Docling Keycloak integration and provide required auth settings
- **THEN** ingress/auth behavior uses the configured Keycloak-compatible contract
- **AND** the integration supports either a local Keycloak module or an external Keycloak endpoint

### Requirement: Docling observability integration is optional and safe by default
The system SHALL provide optional observability hooks for Docling compatible with repository observability patterns without public telemetry exposure by default.

#### Scenario: Observability disabled
- **WHEN** Docling runs with observability integration disabled
- **THEN** Docling startup and operation do not require observability services

#### Scenario: Observability enabled
- **WHEN** operators enable observability integration for Docling
- **THEN** Docling exposes documented telemetry hooks compatible with repository observability patterns
- **AND** telemetry interfaces remain non-public by default unless explicitly configured otherwise
