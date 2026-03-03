## ADDED Requirements

### Requirement: Rocket.Chat service module behind Traefik
The system SHALL provide an optional Rocket.Chat service module under `services/rocketchat/` that runs behind Traefik with HTTPS routing and profile-gated lifecycle commands.

#### Scenario: Rocket.Chat profile is enabled
- **WHEN** the operator runs the Rocket.Chat lifecycle commands or enables the `rocketchat` profile
- **THEN** Docker Compose includes Rocket.Chat and its required dependencies (MongoDB replica set bootstrap and NATS)
- **AND** Traefik routes `https://rocketchat.<DEV_DOMAIN>` to the Rocket.Chat application service
- **AND** the module remains disabled during default stack runs unless the profile is explicitly enabled

### Requirement: Rocket.Chat bootstrap rendering and optional integration hooks
The system SHALL provide a bootstrap/render workflow that generates a deterministic Rocket.Chat runtime env file and optional integration guidance artifacts from `.env` values.

#### Scenario: Bootstrap renders Rocket.Chat config
- **WHEN** the operator runs `make rocketchat-bootstrap`
- **THEN** the system writes a rendered Rocket.Chat env file used by the compose service
- **AND** it renders a Keycloak custom OAuth setup checklist containing the callback URL and endpoint guidance when Keycloak integration is enabled
- **AND** observability-related settings are disabled by default unless explicitly enabled

### Requirement: Rocket.Chat operational documentation and tests
The system SHALL document and statically test Rocket.Chat module wiring, guardrails, and bootstrap rendering.

#### Scenario: Contributor validates Rocket.Chat module without full runtime startup
- **WHEN** the contributor runs the Rocket.Chat static smoke suite
- **THEN** tests verify Make target wiring, preflight guardrails, and rendered config behavior
- **AND** the service docs describe runtime commands, optional Keycloak/observability hooks, and TLS mode compatibility notes
