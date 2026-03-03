## ADDED Requirements
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
