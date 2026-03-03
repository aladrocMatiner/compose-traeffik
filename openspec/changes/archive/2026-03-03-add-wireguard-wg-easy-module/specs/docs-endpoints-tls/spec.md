## MODIFIED Requirements

### Requirement: README endpoints and quickstart
The system SHALL document all real endpoints and a self-signed quickstart in the root README. Endpoint documentation SHALL cover HTTP(S) UI endpoints and any additional protocol endpoints (for example UDP service endpoints) using repo-accurate hostnames/ports, profile enablement notes, and security notes based on repo configuration.

#### Scenario: Endpoint listing
- **WHEN** a user reads the Endpoints section
- **THEN** each endpoint includes hostname plus URL or protocol/port notation, profile enablement, and security notes based on repo configuration
- **AND** optional profile endpoints (including WireGuard UI/tunnel when documented) are clearly labeled as optional

#### Scenario: Self-signed quickstart
- **WHEN** a user follows the Quick start (Self-signed TLS)
- **THEN** they can complete setup using existing Make targets and scripts

### Requirement: TLS guides under docs/
The system SHALL provide complete TLS setup guides for Mode A/B/C under `docs/` with prerequisites, steps, expected result, verification, common pitfalls, and troubleshooting.

#### Scenario: Guide completeness
- **WHEN** a user reads any TLS guide
- **THEN** it includes the required sections and uses repo-accurate commands and paths

