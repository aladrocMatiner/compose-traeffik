## MODIFIED Requirements
### Requirement: README endpoints and quickstart
The system SHALL document all real endpoints, including optional module endpoints such as Grafana, and a self-signed quickstart in the root README.

#### Scenario: Endpoint listing
- **WHEN** a user reads the Endpoints section
- **THEN** each endpoint includes hostname, URL, profile enablement, and security notes based on repo configuration
- **AND** the Grafana endpoint `https://grafana.${DEV_DOMAIN}` is listed with its `observability` profile note
- **AND** Prometheus and Loki are documented as internal-only by default unless a future change adds explicit exposure

#### Scenario: Self-signed quickstart
- **WHEN** a user follows the Quick start (Self-signed TLS)
- **THEN** they can complete setup using existing Make targets and scripts
