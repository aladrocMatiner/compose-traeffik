## MODIFIED Requirements

### Requirement: README endpoints and quickstart
The system SHALL document all real endpoints and a self-signed quickstart in the root README. For new services with observability options, the README SHALL also document the telemetry exposure posture (for example, internal-only by default).

#### Scenario: Endpoint listing
- **WHEN** a user reads the Endpoints section
- **THEN** each endpoint includes hostname, URL, profile enablement, and security notes based on repo configuration

#### Scenario: New service with observability option
- **WHEN** a new service module supports observability integration
- **THEN** the root and/or service documentation states whether telemetry endpoints are disabled, internal-only, or publicly exposed by default

#### Scenario: Self-signed quickstart
- **WHEN** a user follows the Quick start (Self-signed TLS)
- **THEN** they can complete setup using existing Make targets and scripts
