## MODIFIED Requirements
### Requirement: README endpoints and quickstart
The system SHALL document all real endpoints and a self-signed quickstart in the root README files, including an explicit env generator option for creating `.env` from `.env.example`.

#### Scenario: Endpoint listing
- **WHEN** a user reads the Endpoints section
- **THEN** each endpoint includes hostname, URL, profile enablement, and security notes based on repo configuration

#### Scenario: Self-signed quickstart
- **WHEN** a user follows the Quick start (Self-signed TLS)
- **THEN** they can complete setup using existing Make targets and scripts
- **AND** the quickstart includes a script-based `.env` generation option
