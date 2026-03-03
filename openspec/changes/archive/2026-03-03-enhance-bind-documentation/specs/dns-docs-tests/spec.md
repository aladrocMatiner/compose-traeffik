## MODIFIED Requirements

### Requirement: DNS documentation index and guide
The system SHALL include a documentation index and a DNS service guide under `docs/` that explains setup, provisioning, security, and verification steps for the active DNS workflow in this branch.

#### Scenario: Docs index
- **WHEN** a developer opens `docs/README.md`
- **THEN** they can find a link to the DNS service guide
- **AND** the label clearly indicates BIND-oriented guidance

#### Scenario: DNS service guide content
- **WHEN** a developer reads `docs/06-howto/service-dns-bind.md`
- **THEN** it includes setup steps, Make targets, security notes, and verification commands aligned with `.env.example`
- **AND** troubleshooting guidance reflects BIND behavior and naming

### Requirement: DNS service verification tests
The system SHALL provide no-sudo tests that verify the DNS service configuration and expected DNS-related integration checks.

#### Scenario: Compose configuration validation
- **WHEN** DNS verification tests run
- **THEN** they confirm the active DNS service configuration and localhost-only port 53 binding expectations
- **AND** test references in docs remain aligned with the actual executed smoke checks
