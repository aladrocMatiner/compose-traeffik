## ADDED Requirements

### Requirement: Semaphore UI endpoint and TLS guidance in root docs
The system SHALL document the Semaphore UI endpoint, profile, and TLS mode considerations in the root multilingual READMEs.

#### Scenario: Semaphore UI endpoint discoverability
- **WHEN** a user reads the root README Endpoints or Services section
- **THEN** they can identify the Semaphore UI hostname, URL pattern, profile, and access path via Traefik
- **AND** the docs note any `ENDPOINTS`/hosts mapping steps needed for local TLS modes
