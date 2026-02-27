## ADDED Requirements
### Requirement: Optional observability stack module for Traefik-based deployments
The system SHALL provide an optional module under `services/observability/` that deploys Prometheus, Grafana, Loki, and a log collector agent to monitor the edge stack, with Traefik telemetry as the reusable baseline for any deployment.

#### Scenario: Observability profile enabled
- **WHEN** the `observability` profile is enabled and the module is started
- **THEN** Grafana, Prometheus, Loki, and the collector agent services are created with repo-managed configuration files

#### Scenario: App modules absent
- **WHEN** the `observability` profile is enabled without an app module such as `ctfd`
- **THEN** the observability stack still runs for Traefik telemetry
- **AND** app-specific dashboards or queries may show no data without causing stack failure

#### Scenario: Internal-only backends by default
- **WHEN** a user inspects the module compose configuration
- **THEN** Prometheus and Loki are not exposed via host ports or public Traefik routers by default
- **AND** Grafana is the only observability UI exposed through Traefik by default

#### Scenario: Prometheus can scrape Traefik without public exposure
- **WHEN** the observability module is configured for default Traefik metrics collection
- **THEN** the `prometheus` service has Docker-network reachability to the Traefik metrics endpoint (for example by joining the `proxy` network used by Traefik)
- **AND** this reachability does not require exposing Traefik metrics on a public host port or public router
- **AND** the `prometheus` service itself remains internal-only (no host port and no public Traefik router by default)

### Requirement: Phase-1 telemetry coverage with reusable baseline and initial app pack
The system SHALL provide phase-1 telemetry coverage consisting of a reusable Traefik telemetry baseline (Prometheus metrics + logs) and an initial app integration pack for CTFd logs ingested into Loki and viewable from Grafana.

#### Scenario: Traefik metrics scrape path configured
- **WHEN** Prometheus starts with the observability config
- **THEN** it has a scrape target for Traefik metrics on the Docker network

#### Scenario: Container logs pipeline configured
- **WHEN** the collector agent starts with the observability config
- **THEN** it is configured to ship logs from `traefik` and the initial app target containers (including `ctfd*`) to Loki
- **AND** the configuration tolerates missing app target containers without failing startup

#### Scenario: Grafana datasources provisioned
- **WHEN** Grafana starts
- **THEN** Prometheus and Loki datasources are provisioned automatically without manual UI setup

### Requirement: Extensible observability integration pattern for future services
The system SHALL structure observability configuration and documentation so future Traefik-routed services can add logs/queries/dashboards without redesigning the core observability stack.

#### Scenario: Future service extension
- **WHEN** a contributor adds observability support for a new service module after CTFd
- **THEN** they can add service-specific collector filters or Grafana assets alongside existing core assets
- **AND** the core observability topology and Traefik telemetry baseline remain unchanged

### Requirement: Bounded local retention defaults
The system SHALL provide bounded local retention defaults for observability data to reduce disk growth risk in local and small self-hosted deployments.

#### Scenario: Default observability deployment
- **WHEN** a user starts the observability module with default settings
- **THEN** Prometheus and Loki use finite retention/storage settings defined by config and/or startup flags
- **AND** the defaults can be adjusted through documented configuration variables

### Requirement: Observability bootstrap, guardrails, docs, and smoke tests
The system SHALL provide a bootstrap flow for Grafana admin secrets, profile-gated preflight validation, module documentation, and no-sudo smoke tests.

#### Scenario: Observability bootstrap
- **WHEN** a user runs `make observability-bootstrap` with missing Grafana secrets in `.env`
- **THEN** secure values are generated and persisted in `.env`
- **AND** subsequent runs preserve existing values unless explicit rotation is requested

#### Scenario: Documentation communicates scope and defaults
- **WHEN** a user reads the root and module documentation
- **THEN** they can identify the Grafana endpoint, the internal-only default status of Prometheus/Loki, the Traefik-first reusable model, and the phase-1 telemetry scope/limitations for CTFd
