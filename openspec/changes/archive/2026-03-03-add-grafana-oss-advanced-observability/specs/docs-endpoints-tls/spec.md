## ADDED Requirements
### Requirement: Multi-signal observability scope and exposure model in docs
The documentation SHALL describe the expanded observability signal model and explicitly distinguish public versus internal-only endpoints for advanced Grafana OSS backends.

#### Scenario: User reads endpoint and observability sections
- **WHEN** a user reads root and module documentation
- **THEN** Grafana is documented as the public observability UI endpoint
- **AND** Prometheus, Loki, Tempo, and Pyroscope are documented as internal-only by default
- **AND** k6 usage is documented as an on-demand command path rather than a public service endpoint

#### Scenario: User reads observability signal matrix
- **WHEN** a user reviews observability docs
- **THEN** they can identify which component is responsible for metrics, logs, traces, profiles, and synthetic checks
