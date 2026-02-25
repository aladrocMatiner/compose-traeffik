## ADDED Requirements
### Requirement: Optional Keycloak service module behind Traefik
The system SHALL provide an optional Keycloak service module under `services/keycloak/` that runs behind Traefik HTTPS using the repository's compose/Makefile conventions.

#### Scenario: Keycloak profile enabled
- **WHEN** the `keycloak` profile is enabled and the module is started
- **THEN** Keycloak and its database dependency are created with repo-managed configuration and persistence
- **AND** the Keycloak UI/API is reachable through Traefik at `https://keycloak.<DEV_DOMAIN>`

#### Scenario: Keycloak profile disabled
- **WHEN** the `keycloak` profile is not enabled
- **THEN** the base stack behavior remains unchanged and no Keycloak containers are started

#### Scenario: Database is internal-only by default
- **WHEN** a user inspects the Keycloak compose configuration
- **THEN** the Keycloak database service is not exposed via host ports or public Traefik routers by default
- **AND** Keycloak reaches the database through internal compose networking

### Requirement: Keycloak is configured for reverse-proxy TLS termination
The Keycloak module SHALL be configured for Traefik reverse proxy operation so login and admin UI traffic work correctly when TLS is terminated at Traefik.

#### Scenario: Access through Traefik HTTPS
- **WHEN** a user accesses Keycloak via `https://keycloak.<DEV_DOMAIN>`
- **THEN** Keycloak uses the configured hostname/proxy settings compatible with Traefik
- **AND** the module documentation describes the required proxy/TLS assumptions

### Requirement: Keycloak bootstrap and lifecycle are repo-native
The system SHALL provide bootstrap and lifecycle flows for Keycloak that match repository patterns (Make targets, `.env` secrets, docs, smoke tests).

#### Scenario: Initial bootstrap
- **WHEN** a user runs the Keycloak bootstrap target with missing credentials in `.env`
- **THEN** secure values are generated and persisted in `.env`
- **AND** reruns preserve existing values unless explicit rotation is requested

### Requirement: Keycloak observability integration is optional and safe-by-default
The Keycloak module SHALL define optional observability integration hooks compatible with a Grafana/Prometheus/Loki collector stack, while keeping observability disabled and non-public by default.

#### Scenario: Observability disabled
- **WHEN** Keycloak runs with observability option disabled
- **THEN** no observability backend dependency is required
- **AND** Keycloak remains functional behind Traefik

#### Scenario: Observability enabled
- **WHEN** Keycloak observability option is enabled and a compatible observability stack is present
- **THEN** Keycloak exposes documented metrics/log integration points for scraping/ingestion
- **AND** metrics/log interfaces are not publicly exposed by default through Traefik unless explicitly configured

#### Scenario: Observability assets follow reusable service-pack pattern
- **WHEN** the module provides Keycloak-specific observability dashboards, labels, or query hints
- **THEN** they are organized as service-specific assets or documentation that plug into the reusable observability stack pattern
- **AND** they do not require redesign of the core observability topology
