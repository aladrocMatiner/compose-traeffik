## ADDED Requirements
### Requirement: New service modules define an optional observability integration contract
Every new service module added after this specification SHALL define how it integrates with the project's optional observability stack pattern (Grafana/Prometheus/Loki/collector) when observability is enabled.

#### Scenario: New service proposal is created
- **WHEN** a contributor proposes a new service module
- **THEN** the proposal/specs describe whether and how the service exposes metrics and/or logs for the optional observability stack
- **AND** the proposal explicitly documents disabled-mode behavior when observability is not enabled

### Requirement: Observability integration is safe-by-default
New service observability integrations SHALL avoid public telemetry exposure by default unless an explicit public exposure path is documented and justified.

#### Scenario: Observability option enabled for a new service
- **WHEN** a service's observability option is enabled
- **THEN** telemetry endpoints and log pipelines are configured for internal collection by default
- **AND** public access to telemetry interfaces is not enabled implicitly

### Requirement: Observability option is documented and testable
New service modules SHALL document observability behavior (enabled vs disabled) and include smoke-test coverage or manual validation guidance for observability wiring.

#### Scenario: Contributor inspects service docs/tests
- **WHEN** a contributor reviews a new service module's docs and tests
- **THEN** they can identify the observability toggle/configuration and the validation approach (smoke test and/or manual checklist)

#### Scenario: Metrics endpoints remain non-public by default
- **WHEN** a new service exposes a metrics or management endpoint for observability
- **THEN** the service documentation and tests describe how internal collection works
- **AND** they confirm the endpoint is not publicly routed by default unless explicitly documented and justified
