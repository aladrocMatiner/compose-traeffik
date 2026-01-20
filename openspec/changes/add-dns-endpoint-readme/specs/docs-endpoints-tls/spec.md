## MODIFIED Requirements
### Requirement: README endpoints and quickstart
The system SHALL document all real endpoints, including the DNS UI endpoint, and a self-signed quickstart in the root README files.

#### Scenario: Endpoint listing
- **WHEN** a user reads the Endpoints section
- **THEN** each endpoint includes hostname, URL, profile enablement, and security notes based on repo configuration
- **AND** the DNS UI endpoint `https://dns.${BASE_DOMAIN}` is listed with its `dns` profile note

#### Scenario: Self-signed quickstart
- **WHEN** a user follows the Quick start (Self-signed TLS)
- **THEN** they can complete setup using existing Make targets and scripts
