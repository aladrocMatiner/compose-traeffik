## MODIFIED Requirements

### Requirement: README endpoints and quickstart
The system SHALL document all real endpoints and a self-signed quickstart in the root README. GitLab additions SHALL include both the HTTPS UI endpoint and the SSH clone port behavior.

#### Scenario: Endpoint listing
- **WHEN** a user reads the Endpoints section
- **THEN** each endpoint includes hostname, URL, profile enablement, and security notes based on repo configuration

#### Scenario: GitLab endpoint and SSH notes
- **WHEN** GitLab is available as a module
- **THEN** the root README documents `https://gitlab.<DEV_DOMAIN>` and the configurable Git SSH host port
- **AND** it states whether SSH is routed outside Traefik by default

#### Scenario: Self-signed quickstart
- **WHEN** a user follows the Quick start (Self-signed TLS)
- **THEN** they can complete setup using existing Make targets and scripts
