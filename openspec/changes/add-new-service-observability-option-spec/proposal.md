# Change: Add Observability Option Specification for New Service Modules

## Why
The project is adding more services over time. Observability integration is currently handled ad hoc per module/branch. A reusable specification is needed so every new service defines how it can be monitored by the optional Grafana Labs stack (Prometheus/Grafana/Loki/collector) without making observability a hard dependency.

## What Changes
- Add a cross-cutting specification that requires new service modules to define an optional observability integration contract.
- Define minimum expectations for docs, tests, and safe defaults (internal-only telemetry by default, no public metrics exposure unless explicitly documented).
- Clarify that services must remain functional when observability is disabled.

## Impact
- Affected specs: `service-observability-option` (new), `services-layout`, `tests-docs`, `tests-suite`, `scripts-docs`
- Affected code: none in this planning-only change; future service changes must comply
