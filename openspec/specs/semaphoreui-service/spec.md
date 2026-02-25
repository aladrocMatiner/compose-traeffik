# semaphoreui-service Specification

## Purpose
TBD - created by archiving change add-semaphoreui-service-module. Update Purpose after archive.
## Requirements
### Requirement: Semaphore UI service module with Traefik subdomain routing
The system SHALL provide a `semaphoreui` service module under `services/semaphoreui/` that runs behind Traefik on a configurable subdomain and does not expose the application UI/API directly on host ports by default.

#### Scenario: Semaphore UI module layout
- **WHEN** a contributor inspects `services/semaphoreui/`
- **THEN** they find a `compose.yml` and service documentation
- **AND** the compose fragment defines the `semaphoreui` profile

#### Scenario: Traefik-only UI exposure
- **WHEN** the Semaphore UI profile is enabled with default settings
- **THEN** Traefik routes HTTPS traffic to the Semaphore UI service using the configured hostname
- **AND** the Semaphore UI container does not publish host ports by default

### Requirement: Internal database dependency for Semaphore UI
The system SHALL provide a PostgreSQL dependency for Semaphore UI with persistent storage and internal-only networking by default.

#### Scenario: Internal DB deployment
- **WHEN** the Semaphore UI profile is enabled
- **THEN** the compose configuration includes a PostgreSQL service for Semaphore UI
- **AND** the database service uses a persistent volume
- **AND** the database service is not publicly exposed by default

### Requirement: Optional Keycloak OIDC login configuration
The system SHALL support an optional OIDC configuration path for Semaphore UI that can be wired to Keycloak without making Keycloak a hard runtime dependency.

#### Scenario: OIDC disabled by default
- **WHEN** a user bootstraps Semaphore UI with default settings
- **THEN** OIDC integration is disabled
- **AND** Semaphore UI can still be accessed with local credentials

#### Scenario: OIDC enabled with Keycloak-compatible settings
- **WHEN** a user enables OIDC and provides the required provider/client settings
- **THEN** the Semaphore UI configuration renders or maps a valid OIDC provider definition for the container
- **AND** the service remains reachable behind Traefik at the configured hostname

### Requirement: Optional observability hooks with safe defaults
The system SHALL support optional observability hooks for Semaphore UI that are compatible with the repository's Grafana/Prometheus/Loki/collector pattern while remaining safe when disabled.

#### Scenario: Observability disabled
- **WHEN** observability is disabled for Semaphore UI
- **THEN** the service starts normally without requiring any observability components
- **AND** no additional public telemetry endpoint is exposed

#### Scenario: Observability enabled
- **WHEN** observability is enabled for Semaphore UI
- **THEN** the compose and documentation define how logs and supported telemetry are discovered/collected
- **AND** telemetry endpoints (if any) remain internal-only unless explicitly documented and enabled

