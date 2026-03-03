## ADDED Requirements
### Requirement: Observability profile preflight validation
The system SHALL validate observability-required environment variables before compose runs when the `observability` profile is enabled.

#### Scenario: Missing Grafana admin password
- **WHEN** `COMPOSE_PROFILES` includes `observability` and `GRAFANA_ADMIN_PASSWORD` is missing or a placeholder
- **THEN** preflight validation fails with a clear message that points to `make observability-bootstrap`

#### Scenario: Observability profile disabled
- **WHEN** the `observability` profile is not enabled
- **THEN** observability-specific validation checks do not block unrelated stack workflows

#### Scenario: Observability enabled without app telemetry targets
- **WHEN** `COMPOSE_PROFILES` includes `observability` but app modules such as `ctfd` are not enabled
- **THEN** preflight validation MAY emit a guidance warning about partial dashboards
- **AND** it MUST NOT fail because Traefik-only observability is a supported mode

#### Scenario: Missing retention variables uses safe defaults
- **WHEN** the `observability` profile is enabled and optional retention variables are unset
- **THEN** preflight validation does not fail
- **AND** documentation and module defaults still provide bounded retention behavior
