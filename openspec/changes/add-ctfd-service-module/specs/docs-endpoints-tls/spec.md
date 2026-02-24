## MODIFIED Requirements
### Requirement: README endpoints and quickstart
The system SHALL document all real endpoints, including optional module endpoints such as CTFd, and a self-signed quickstart in the root README.

#### Scenario: Endpoint listing
- **WHEN** a user reads the Endpoints section
- **THEN** each endpoint includes hostname, URL, profile enablement, and security notes based on repo configuration
- **AND** the CTFd endpoint `https://ctfd.${DEV_DOMAIN}` is listed with its `ctfd` profile note

#### Scenario: Self-signed quickstart
- **WHEN** a user follows the Quick start (Self-signed TLS)
- **THEN** they can complete setup using existing Make targets and scripts
