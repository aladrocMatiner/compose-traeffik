## ADDED Requirements
### Requirement: Traefik emits metrics and structured access logs for observability
The system SHALL configure Traefik to emit Prometheus metrics and structured access logs suitable for ingestion by the observability stack, as a reusable baseline for Traefik-routed deployments.

#### Scenario: Prometheus metrics enabled
- **WHEN** Traefik starts with the repository static configuration
- **THEN** Prometheus metrics are available on an internal Traefik endpoint for Docker-network scraping
- **AND** metrics include entrypoint/router/service labels needed for Grafana dashboards

#### Scenario: Access logs are structured
- **WHEN** Traefik handles requests
- **THEN** access logs are emitted in a structured format suitable for log parsing and Loki ingestion

#### Scenario: Sensitive headers are not logged by default
- **WHEN** Traefik emits access logs with the default observability configuration
- **THEN** sensitive request headers such as `Authorization` and cookies are excluded or redacted by default

#### Scenario: Observability profile disabled
- **WHEN** the `observability` profile is not enabled
- **THEN** Traefik telemetry emission remains configured as an internal-only baseline
- **AND** no observability backend UI/API is exposed by this setting alone

### Requirement: Traefik metrics are not publicly exposed by default
The system SHALL avoid public exposure of Traefik metrics while enabling internal scraping.

#### Scenario: Default observability setup
- **WHEN** the observability module is enabled with default settings
- **THEN** no additional public host port or public Traefik router is created for the Traefik metrics endpoint
