## ADDED Requirements

### Requirement: Optional WireGuard server module with wg-easy
The system SHALL provide an optional WireGuard server module implemented as a dedicated service under `services/wg-easy/` and activated via the `wg` Docker Compose profile.

#### Scenario: Default stack remains unchanged
- **WHEN** a user runs `make up` without enabling profile `wg`
- **THEN** the `wg-easy` service is not started
- **AND** existing non-WireGuard services keep their prior behavior

#### Scenario: WireGuard profile is enabled
- **WHEN** a user enables profile `wg` (for example via `COMPOSE_PROFILES=wg` or a dedicated Make target)
- **THEN** Docker Compose includes the `wg-easy` service from `services/wg-easy/compose.yml`
- **AND** the service joins the stack using the project’s standard compose layering

### Requirement: HTTPS-only admin UI through Traefik
The system SHALL expose the `wg-easy` administration UI through Traefik over HTTPS and SHALL NOT publish the UI TCP port directly on the host by default.

#### Scenario: Admin UI exposure
- **WHEN** the `wg` profile is active
- **THEN** the `wg-easy` service is routable through Traefik on a hostname derived from configuration (default `wg.<DEV_DOMAIN>`)
- **AND** the route uses the `websecure` entrypoint with TLS enabled
- **AND** the router follows the project TLS resolver pattern so it remains compatible with Mode A/B/C TLS workflows

#### Scenario: No direct UI host port publishing
- **WHEN** a user inspects the WireGuard compose service definition
- **THEN** the service does not publish the web administration TCP port to the host
- **AND** UI access is intended to occur through Traefik routing

### Requirement: Hardened container runtime defaults for WireGuard service
The system SHALL configure the `wg-easy` container with the minimum required privileges for WireGuard operation and SHALL avoid broad privilege escalation defaults.

#### Scenario: Compose definition avoids broad privilege escalation
- **WHEN** a contributor inspects `services/wg-easy/compose.yml`
- **THEN** the service does not rely on `privileged: true` by default
- **AND** required capabilities/devices are declared explicitly for WireGuard operation

#### Scenario: Host prerequisites are documented
- **WHEN** a user reads the WireGuard service README
- **THEN** it documents required host capabilities and prerequisites (for example TUN device or forwarding-related settings)
- **AND** it explains likely failure modes when the host does not support them

### Requirement: Configurable WireGuard UDP endpoint exposure
The system SHALL publish the WireGuard tunnel UDP port using environment-driven configuration and document the advertised endpoint used by clients.

#### Scenario: Default UDP port
- **WHEN** the `wg` profile is active and no override is set
- **THEN** the service publishes the default WireGuard UDP port (`51820/udp`) to the host
- **AND** documentation identifies the default endpoint host and port for client configuration

#### Scenario: Operator customizes UDP port
- **WHEN** the operator sets the configured WireGuard UDP port variable in `.env`
- **THEN** the published host UDP port matches that value
- **AND** the compose service remains valid without requiring changes to unrelated services

### Requirement: Explicit WireGuard UDP bind exposure policy
The system SHALL make the WireGuard host bind address explicit in configuration and SHALL require an explicit operator acknowledgement before non-local bind exposure if the project’s guardrail policy defines that requirement.

#### Scenario: Loopback-only bind for local testing
- **WHEN** the WireGuard bind address is configured as loopback
- **THEN** the compose service publishes the UDP port only on the loopback interface
- **AND** documentation explains that remote VPN clients will not reach the service until non-local exposure is intentionally enabled

#### Scenario: Non-local bind is intentional
- **WHEN** the operator configures a non-loopback bind address for the WireGuard UDP port
- **THEN** the compose and preflight flow require the corresponding explicit override/acknowledgement variable per project policy
- **AND** the documentation describes the security implications

### Requirement: Dedicated lifecycle interface for WireGuard operations
The system SHALL provide Makefile lifecycle targets for the WireGuard module that use the project’s compose wrapper and are scoped to the `wg-easy` service.

#### Scenario: Start and inspect WireGuard module
- **WHEN** an operator runs `make wg-up`, `make wg-status`, or `make wg-logs`
- **THEN** the commands invoke the shared compose wrapper with profile `wg`
- **AND** the commands are scoped to the WireGuard service flow
- **AND** the commands preserve the project’s deterministic compose project settings

#### Scenario: Stop WireGuard module
- **WHEN** an operator runs `make wg-down`
- **THEN** the `wg-easy` container is stopped/removed without requiring manual compose commands
- **AND** unrelated services are not targeted by default
### Requirement: Project TLS mode compatibility for WireGuard UI routing
The system SHALL wire the `wg-easy` HTTPS router to the same environment-driven TLS resolver pattern used by other Traefik-routed services so the UI works across the project’s TLS modes.

#### Scenario: Mode A self-signed routing
- **WHEN** the stack runs in Mode A with file-based TLS and an empty resolver
- **THEN** the `wg-easy` router remains valid and serves over HTTPS through Traefik without requiring a resolver value

#### Scenario: Mode B or C ACME routing
- **WHEN** the stack runs in Mode B or Mode C and `TLS_CERT_RESOLVER` is set by the existing workflow
- **THEN** the `wg-easy` router uses that resolver value consistently with other services

### Requirement: Persistent WireGuard service state is stored safely
The system SHALL persist `wg-easy` runtime state in a documented location under `services/wg-easy/` (or an explicitly documented equivalent) and SHALL prevent accidental git commits of generated secrets/configuration.

#### Scenario: First-time startup creates state
- **WHEN** the WireGuard module starts for the first time
- **THEN** the service stores generated state in the configured persistence location
- **AND** operators can identify that location from the service README

#### Scenario: Generated secrets are not tracked
- **WHEN** `wg-easy` creates runtime data files under the documented persistence path
- **THEN** git ignores those generated files by default
- **AND** tracked documentation files in `services/wg-easy/` remain versioned

### Requirement: Administrative credential bootstrap uses .env and Make target
The system SHALL define the initial `wg-easy` administrative credential bootstrap as environment-managed values stored in `.env` and SHALL provide a dedicated `make wg-bootstrap` workflow to populate those values and document safe rotation.

#### Scenario: First-run bootstrap populates `.env`
- **WHEN** an operator runs `make wg-bootstrap` with a valid `.env` and missing WireGuard admin bootstrap variables
- **THEN** the workflow generates and writes the required `WG_*` admin bootstrap values into `.env`
- **AND** the documentation explains how those values are used for first admin access

#### Scenario: Bootstrap is idempotent by default
- **WHEN** an operator reruns `make wg-bootstrap` and the relevant `WG_*` admin values already exist in `.env`
- **THEN** the workflow does not overwrite those values by default
- **AND** the output explains how to perform an explicit rotation if supported

#### Scenario: Missing `.env` is handled safely
- **WHEN** an operator runs `make wg-bootstrap` before creating `.env`
- **THEN** the workflow fails with a clear message or controlled bootstrap path as documented
- **AND** it does not silently create an unsafe partial configuration
