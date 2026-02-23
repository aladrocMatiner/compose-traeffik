## ADDED Requirements

### Requirement: Safe WireGuard profile configuration validation
The system SHALL validate WireGuard profile environment settings before invoking Docker Compose and fail fast on invalid or insecure values when `COMPOSE_PROFILES` includes `wg`.

#### Scenario: Invalid WireGuard UDP port is rejected
- **WHEN** `COMPOSE_PROFILES` includes `wg`
- **AND** the configured WireGuard UDP port is missing, non-numeric, or outside `1-65535`
- **THEN** preflight validation fails with a clear error message naming the WireGuard port variable

#### Scenario: Non-local WireGuard UDP bind requires explicit acknowledgement
- **WHEN** `COMPOSE_PROFILES` includes `wg`
- **AND** the configured WireGuard bind address is non-loopback
- **AND** the WireGuard non-local bind override/acknowledgement variable is not enabled
- **THEN** preflight validation fails with a clear error message describing how to intentionally allow non-local exposure

#### Scenario: Explicit acknowledgement allows non-local WireGuard bind
- **WHEN** `COMPOSE_PROFILES` includes `wg`
- **AND** the configured WireGuard bind address is non-loopback
- **AND** the WireGuard non-local bind override/acknowledgement variable is enabled
- **THEN** preflight validation allows execution to continue

#### Scenario: Invalid UI hostname or endpoint is rejected
- **WHEN** `COMPOSE_PROFILES` includes `wg`
- **AND** the configured WireGuard UI hostname label or server endpoint host is empty or malformed
- **THEN** preflight validation fails with a clear error message describing what must be corrected

#### Scenario: Reverse-proxyless insecure mode is blocked
- **WHEN** `COMPOSE_PROFILES` includes `wg`
- **AND** the WireGuard UI is configured in an insecure reverse-proxyless mode (for example `WG_INSECURE=true`)
- **THEN** preflight validation fails and instructs the operator to keep the UI behind Traefik/TLS
