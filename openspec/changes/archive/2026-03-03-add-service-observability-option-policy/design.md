## Context
The repository has started adding services that may integrate with a reusable observability stack (Grafana/Prometheus/Loki/collector). Without an explicit policy, implementations can forget observability hooks, expose telemetry publicly, or omit documentation/tests.

## Goals
- Make observability integration an explicit planning item for every new service.
- Preserve modularity: services remain deployable without an observability stack.
- Enforce secure defaults and documentation/test expectations.

## Non-Goals
- Shipping or requiring a specific observability stack in every service branch.
- Standardizing one exporter/collector implementation for all services.

## Policy Model
Each new service proposal must address:
- Whether observability integration is supported (default: yes, optional)
- Which signals are available (logs, health, metrics)
- How telemetry remains non-public by default
- How integration is documented and smoke-tested
- Any runtime prerequisites if an observability stack is enabled
