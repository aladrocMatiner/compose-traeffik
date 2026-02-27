## ADDED Requirements
### Requirement: Advanced observability smoke coverage
The smoke test suite SHALL include static/no-sudo checks for advanced observability wiring and provisioning.

#### Scenario: Contributor runs observability smoke suite
- **WHEN** a contributor runs the observability smoke test set
- **THEN** tests verify Tempo/Pyroscope compose wiring and internal-only exposure defaults
- **AND** tests verify Alloy trace/profile pipeline presence
- **AND** tests verify Grafana datasource provisioning for Tempo/Pyroscope
- **AND** tests verify k6 target wiring and script availability
