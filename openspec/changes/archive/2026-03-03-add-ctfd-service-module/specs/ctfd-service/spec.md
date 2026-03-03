## ADDED Requirements
### Requirement: Optional CTFd service module with Traefik routing
The system SHALL provide an optional profile-gated CTFd module under `services/ctfd/` that deploys the CTFd application behind Traefik using the repository's standard HTTP/HTTPS router pattern.

#### Scenario: CTFd profile enabled
- **WHEN** the `ctfd` profile is enabled and the stack is started
- **THEN** a CTFd application service is created and routed via Traefik at `https://ctfd.${DEV_DOMAIN}`
- **AND** the service is not exposed via a direct host HTTP port by default

#### Scenario: TLS mode compatibility
- **WHEN** TLS Mode A, B, or C is active through the existing `TLS_CERT_RESOLVER` wiring
- **THEN** the CTFd HTTPS router follows the same resolver behavior as other app services

### Requirement: Private stateful dependencies and persistence for CTFd
The system SHALL run CTFd with private database/cache dependencies and persistent storage suitable for local development and small self-hosted deployments.

#### Scenario: Internal DB/cache only
- **WHEN** a user inspects the CTFd compose configuration
- **THEN** the database and Redis services do not publish host ports by default
- **AND** they communicate with the CTFd app over an internal Docker network

#### Scenario: Persistent state survives container recreation
- **WHEN** the CTFd, DB, or Redis containers are recreated
- **THEN** configured named volumes preserve database, cache (if persisted), uploads, and logs according to the module design

#### Scenario: Startup coordination avoids dependency races
- **WHEN** the CTFd module starts with a cold database/cache
- **THEN** the compose configuration includes healthchecks and/or startup coordination that reduce app startup failures caused by DB/Redis readiness races

### Requirement: CTFd bootstrap, guardrails, docs, and smoke tests
The system SHALL provide a bootstrap flow for required CTFd secrets, profile-gated validation checks, module documentation, and no-sudo smoke tests aligned with existing project workflows.

#### Scenario: First-time bootstrap
- **WHEN** a user runs `make ctfd-bootstrap` with missing CTFd secrets in `.env`
- **THEN** required secrets are generated and persisted in `.env`
- **AND** subsequent runs do not overwrite them without an explicit rotation/force flag

#### Scenario: Profile-gated preflight validation
- **WHEN** the `ctfd` profile is enabled and required CTFd secrets are missing or placeholders
- **THEN** preflight validation fails with a clear error message before Docker Compose runs

#### Scenario: Documentation and tests discoverability
- **WHEN** a user reviews the root and service documentation plus `tests/README.md`
- **THEN** they can find CTFd setup steps, first-run notes, Make targets, and the corresponding smoke tests
