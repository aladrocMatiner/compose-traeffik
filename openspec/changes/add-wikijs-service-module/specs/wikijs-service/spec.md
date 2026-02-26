## ADDED Requirements

### Requirement: Wiki.js service module behind Traefik
The system SHALL provide an optional Wiki.js service module under `services/wikijs/` that runs behind Traefik with HTTPS routing and profile-gated lifecycle commands.

#### Scenario: Wiki.js profile is enabled
- **WHEN** the operator enables the `wikijs` profile or runs Wiki.js lifecycle commands
- **THEN** Docker Compose includes the Wiki.js application and its required database dependency service(s)
- **AND** Traefik routes `https://wiki.<DEV_DOMAIN>` to the Wiki.js service
- **AND** the module remains disabled during default stack runs unless the profile is explicitly enabled

#### Scenario: Wiki.js reverse proxy supports realtime/WebSocket traffic
- **WHEN** the Wiki.js module is deployed behind Traefik
- **THEN** the module configuration documents and applies the proxy settings needed for Wiki.js realtime/WebSocket traffic as required by the verified upstream guidance
- **AND** runtime validation includes a WebSocket-capable check through Traefik

### Requirement: Wiki.js bootstrap rendering and optional integration runbooks
The system SHALL provide a bootstrap/render workflow that generates deterministic Wiki.js runtime configuration artifacts and optional integration runbooks from `.env` values.

#### Scenario: Bootstrap renders Wiki.js config artifacts
- **WHEN** the operator runs `make wikijs-bootstrap`
- **THEN** the system writes generated artifacts under a gitignored `services/wikijs/rendered/` directory
- **AND** it renders the inputs needed for the planned Wiki.js runtime configuration
- **AND** it renders optional Keycloak and observability guidance artifacts when those integrations are enabled

### Requirement: Optional Keycloak, observability, and step-ca compatibility hooks
The Wiki.js module SHALL define optional hooks for Keycloak integration, observability, and step-ca compatibility with safe defaults that keep all integrations disabled unless explicitly enabled.

#### Scenario: Optional integrations remain disabled by default
- **WHEN** a developer boots the stack without enabling Wiki.js optional integration toggles
- **THEN** Wiki.js runs without Keycloak-specific configuration hooks and without optional observability hooks
- **AND** the module remains compatible with the stack's selected Traefik TLS mode without exposing additional admin or telemetry endpoints by default

#### Scenario: Observability uses the full upstream-supported path when available
- **WHEN** upstream verification confirms a documented/installable observability path for the target Wiki.js version
- **THEN** the module implements that full supported path behind explicit optional toggles
- **AND** the docs and guardrails reflect the chosen observability mode and required inputs

#### Scenario: Keycloak uses internal PKI via step-ca (planned support)
- **WHEN** a developer enables Wiki.js + Keycloak and the Keycloak issuer uses a step-ca-signed certificate
- **THEN** the module documents and validates the required internal CA trust configuration for Wiki.js outbound HTTPS calls
- **AND** the inbound Wiki.js route continues to use the stack's Traefik TLS mode selection
