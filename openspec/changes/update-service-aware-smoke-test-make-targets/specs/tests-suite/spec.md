## ADDED Requirements
### Requirement: Service-aware smoke suite selection
The smoke test runner (`scripts/healthcheck.sh`) SHALL group smoke tests into common and service-specific suites and select service-specific suites based on which compose services are running.

#### Scenario: No service containers running
- **WHEN** `scripts/healthcheck.sh` runs and no supported service containers are detected as running
- **THEN** it skips service-specific suites
- **AND** it still runs common utility smoke tests that do not require optional service containers

#### Scenario: Observability suite enabled by running services
- **WHEN** `scripts/healthcheck.sh` detects one or more observability services running (`grafana`, `prometheus`, `loki`, or `alloy`)
- **THEN** it executes the observability smoke suite
- **AND** it does not require unrelated suites (such as BIND) to run
