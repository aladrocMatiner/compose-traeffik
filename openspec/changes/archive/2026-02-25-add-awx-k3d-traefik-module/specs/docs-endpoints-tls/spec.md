## MODIFIED Requirements
### Requirement: README endpoints and quickstart
The system SHALL document all real endpoints and a self-signed quickstart in the root README.

#### Scenario: Endpoint listing
- **WHEN** a user reads the Endpoints section
- **THEN** each endpoint includes hostname, URL, profile enablement, and security notes based on repo configuration
- **AND** hybrid modules (such as AWX on k3d) include runtime prerequisites and notes that the service is not Compose-native

#### Scenario: Self-signed quickstart
- **WHEN** a user follows the Quick start (Self-signed TLS)
- **THEN** they can complete setup using existing Make targets and scripts

### Requirement: TLS guides under docs/
The system SHALL provide complete TLS setup guides for Mode A/B/C under `docs/` with prerequisites, steps, expected result, verification, common pitfalls, and troubleshooting.

#### Scenario: Guide completeness
- **WHEN** a user reads any TLS guide
- **THEN** it includes the required sections and uses repo-accurate commands and paths

#### Scenario: AWX behind Traefik uses repo TLS modes
- **WHEN** a user enables the AWX module and accesses AWX via Traefik
- **THEN** the documentation explains that AWX reuses the repo TLS mode selected for Traefik (A/B/C)
- **AND** clarifies where TLS terminates and what backend transport is used to AWX
