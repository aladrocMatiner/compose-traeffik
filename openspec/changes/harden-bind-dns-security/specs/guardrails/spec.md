## ADDED Requirements

### Requirement: Safe default DNS bind exposure
The system SHALL require loopback-only `BIND_BIND_ADDRESS` by default when `bind` profile is enabled, unless an explicit non-local override is set.

#### Scenario: Non-local address blocked by default
- **WHEN** `COMPOSE_PROFILES` includes `bind`
- **AND** `BIND_BIND_ADDRESS` is non-loopback
- **AND** `BIND_ALLOW_NONLOCAL_BIND` is not `true`
- **THEN** preflight validation fails with a clear message

#### Scenario: Explicit override allows non-local bind
- **WHEN** `COMPOSE_PROFILES` includes `bind`
- **AND** `BIND_BIND_ADDRESS` is non-loopback
- **AND** `BIND_ALLOW_NONLOCAL_BIND=true`
- **THEN** preflight validation allows execution to continue

