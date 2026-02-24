## ADDED Requirements
### Requirement: DNS documentation index and guide
The system SHALL include a documentation index and a DNS service guide under `docs/` that explains setup, provisioning, split-DNS configuration, security, and verification steps.

#### Scenario: Docs index
- **WHEN** a developer opens `docs/README.md`
- **THEN** they can find a link to the DNS service guide

#### Scenario: DNS service guide content
- **WHEN** a developer reads `docs/06-howto/service-dns-bind.md`
- **THEN** it includes setup steps, Make targets, security notes, and verification commands aligned with `.env.example`

### Requirement: DNS service verification tests
The system SHALL provide no-sudo tests that verify the DNS service configuration and Traefik exposure expectations.

#### Scenario: Compose configuration validation
- **WHEN** DNS verification tests run
- **THEN** they confirm the DNS service, Traefik labels, and localhost-only port 53 binding are present in `docker-compose.yml`
