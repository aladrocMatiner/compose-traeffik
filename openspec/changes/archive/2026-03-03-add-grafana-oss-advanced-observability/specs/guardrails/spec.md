## ADDED Requirements
### Requirement: Advanced observability preflight validation
The system SHALL validate advanced observability configuration variables when the `observability` profile is enabled, including variables needed for Tempo, Pyroscope, and k6 execution settings.

#### Scenario: Invalid advanced observability variable
- **WHEN** `COMPOSE_PROFILES` includes `observability` and an advanced observability variable has an invalid format/value
- **THEN** preflight validation fails with a clear corrective message

#### Scenario: Safe defaults keep backward compatibility
- **WHEN** existing observability users upgrade without setting new advanced variables
- **THEN** preflight validation accepts the configuration if defaults are safe
- **AND** metrics/logs baseline behavior remains available

#### Scenario: k6 execution without required target config
- **WHEN** a user invokes the k6 synthetic check target and required target URL settings are missing
- **THEN** validation fails early with explicit instructions for required variables
