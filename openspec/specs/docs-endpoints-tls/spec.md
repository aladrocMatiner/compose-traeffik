# docs-endpoints-tls Specification

## Purpose
TBD - created by archiving change update-readme-endpoints-tls-guides. Update Purpose after archive.
## Requirements
### Requirement: README endpoints and quickstart
The system SHALL document all real endpoints and a self-signed quickstart in the root README.

#### Scenario: Endpoint listing
- **WHEN** a user reads the Endpoints section
- **THEN** each endpoint includes hostname, URL, profile enablement, and security notes based on repo configuration

#### Scenario: Self-signed quickstart
- **WHEN** a user follows the Quick start (Self-signed TLS)
- **THEN** they can complete setup using existing Make targets and scripts

### Requirement: TLS guides under docs/
The system SHALL provide complete TLS setup guides for Mode A/B/C under `docs/` with prerequisites, steps, expected result, verification, common pitfalls, and troubleshooting.

#### Scenario: Guide completeness
- **WHEN** a user reads any TLS guide
- **THEN** it includes the required sections and uses repo-accurate commands and paths

### Requirement: Semaphore UI endpoint and TLS guidance in root docs
The system SHALL document the Semaphore UI endpoint, profile, and TLS mode considerations in the root multilingual READMEs.

#### Scenario: Semaphore UI endpoint discoverability
- **WHEN** a user reads the root README Endpoints or Services section
- **THEN** they can identify the Semaphore UI hostname, URL pattern, profile, and access path via Traefik
- **AND** the docs note any `ENDPOINTS`/hosts mapping steps needed for local TLS modes

