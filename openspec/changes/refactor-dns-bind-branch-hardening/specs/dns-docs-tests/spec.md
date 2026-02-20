## MODIFIED Requirements

### Requirement: DNS documentation index and guide
The system SHALL include documentation entries and a DNS guide under `docs/` that explain BIND setup, zone generation, security defaults, and verification steps.

#### Scenario: Docs index
- **WHEN** a developer opens `docs/README.md`
- **THEN** they can find a link to the BIND DNS guide

#### Scenario: DNS service guide content
- **WHEN** a developer reads `docs/06-howto/service-dns-bind.md`
- **THEN** it includes `bind-*` setup steps, BIND-specific notes, and verification commands aligned with `.env.example`

### Requirement: DNS service verification tests
The system SHALL provide no-sudo tests that verify BIND service configuration and expected compose bindings.

#### Scenario: Compose configuration validation
- **WHEN** DNS verification tests run
- **THEN** they confirm the BIND service profile, localhost-only port 53 bindings, and expected config mounts in `services/dns-bind/compose.yml`
- **AND** the test is invoked from `scripts/healthcheck.sh`
