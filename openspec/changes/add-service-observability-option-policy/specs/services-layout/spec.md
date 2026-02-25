## ADDED Requirements

### Requirement: Service documentation includes observability option handling
The system SHALL require each new `services/<service>/README.md` to document observability option handling when the service introduces telemetry hooks, toggles, or integration guidance.

#### Scenario: Service adds observability hooks
- **WHEN** a new service module includes observability-related configuration
- **THEN** its service README explains how the observability option works and whether it is enabled or disabled by default
