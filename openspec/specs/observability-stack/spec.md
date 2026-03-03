# observability-stack Specification

## Purpose
TBD - created by archiving change add-grafana-oss-advanced-observability. Update Purpose after archive.
## Requirements
### Requirement: Multi-signal observability with Grafana OSS components
The system SHALL expand the optional observability module to support four core signals: metrics, logs, traces, and profiles by adding Tempo and Pyroscope to the existing stack.

#### Scenario: Observability profile enabled with advanced signals
- **WHEN** the `observability` profile is enabled and started
- **THEN** the stack includes Grafana, Prometheus, Loki, Alloy, Tempo, and Pyroscope services
- **AND** service configuration is provided from repository-managed files

#### Scenario: Internal-only advanced backends by default
- **WHEN** a user inspects observability compose wiring
- **THEN** Tempo and Pyroscope are not exposed by host ports
- **AND** Tempo and Pyroscope are not exposed through public Traefik routers by default

### Requirement: Alloy routes logs, traces, and profiles
The system SHALL configure Alloy as the collector/forwarder for multi-signal pipelines, preserving current log ingestion while adding trace and profile forwarding.

#### Scenario: Existing logs pipeline remains active
- **WHEN** the expanded observability module is deployed
- **THEN** Traefik and app container logs continue to flow to Loki as before

#### Scenario: Trace pipeline configured
- **WHEN** an instrumented service sends OTLP traces into the stack
- **THEN** Alloy forwards traces to Tempo
- **AND** missing instrumented services do not fail stack startup

#### Scenario: Profile pipeline configured
- **WHEN** an instrumented service sends profiling data into the stack
- **THEN** Alloy forwards profiles to Pyroscope
- **AND** missing profiling sources do not fail stack startup

### Requirement: Grafana auto-provisions trace/profile datasources
The system SHALL auto-provision Tempo and Pyroscope datasources in Grafana, alongside Prometheus and Loki.

#### Scenario: Grafana startup provisioning
- **WHEN** Grafana starts with observability provisioning assets
- **THEN** datasources for Prometheus, Loki, Tempo, and Pyroscope are available without manual UI setup

### Requirement: On-demand synthetic checks with k6
The system SHALL provide an on-demand k6 execution path for synthetic HTTP checks against Traefik-routed endpoints and integrate its results into the observability workflow.

#### Scenario: Synthetic check execution
- **WHEN** a user runs the repository Make target for k6 synthetic checks
- **THEN** a k6 scenario is executed against configured target URLs
- **AND** outputs are available through the documented Grafana-compatible telemetry path

### Requirement: Phase-scope excludes Mimir
The system SHALL keep the advanced observability expansion single-node and MUST NOT require Mimir in this phase.

#### Scenario: Default advanced observability deployment
- **WHEN** a user enables advanced observability features from this change
- **THEN** no distributed metrics backend (Mimir) is required for startup or baseline operation

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

