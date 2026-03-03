# docs-endpoints-tls Specification

## Purpose
TBD - created by archiving change update-readme-endpoints-tls-guides. Update Purpose after archive.
## Requirements
### Requirement: README endpoints and quickstart
The system SHALL document all real endpoints, including optional module endpoints such as CTFd, and a self-signed quickstart in the root README.

#### Scenario: Endpoint listing
- **WHEN** a user reads the Endpoints section
- **THEN** each endpoint includes hostname, URL, profile enablement, and security notes based on repo configuration
- **AND** the CTFd endpoint `https://ctfd.${DEV_DOMAIN}` is listed with its `ctfd` profile note

#### Scenario: Self-signed quickstart
- **WHEN** a user follows the Quick start (Self-signed TLS)
- **THEN** they can complete setup using existing Make targets and scripts

### Requirement: TLS guides under docs/
The system SHALL provide complete TLS setup guides for Mode A/B/C under `docs/` with prerequisites, steps, expected result, verification, common pitfalls, and troubleshooting.

#### Scenario: Guide completeness
- **WHEN** a user reads any TLS guide
- **THEN** it includes the required sections and uses repo-accurate commands and paths

### Requirement: Rocket.Chat endpoint and TLS compatibility notes
The root documentation SHALL list the Rocket.Chat endpoint and describe its compatibility with the repo's Traefik TLS modes, including step-ca as an optional mode.

#### Scenario: Operator enables Rocket.Chat with step-ca
- **WHEN** the operator reads the root README and Rocket.Chat service docs
- **THEN** they can identify the Rocket.Chat hostname and lifecycle commands
- **AND** they see that Rocket.Chat is routed by Traefik and can use the same TLS mode selected for the stack (including optional step-ca)

### Requirement: Semaphore UI endpoint and TLS guidance in root docs
The system SHALL document the Semaphore UI endpoint, profile, and TLS mode considerations in the root multilingual READMEs.

#### Scenario: Semaphore UI endpoint discoverability
- **WHEN** a user reads the root README Endpoints or Services section
- **THEN** they can identify the Semaphore UI hostname, URL pattern, profile, and access path via Traefik
- **AND** the docs note any `ENDPOINTS`/hosts mapping steps needed for local TLS modes

### Requirement: Plane endpoint and optional integration behavior are documented in root docs
The system SHALL document the Plane endpoint, profile usage, and optional integration behavior for Step-CA, Keycloak, and observability in root README guidance.

#### Scenario: User reads endpoint list
- **WHEN** a user reviews the Endpoints section
- **THEN** `https://plane.<DEV_DOMAIN>` is listed with profile and security notes consistent with repository conventions

#### Scenario: User reviews optional integrations
- **WHEN** a user reads Plane setup instructions in root docs
- **THEN** documentation explains how Plane behaves with Step-CA, Keycloak, and observability both enabled and disabled
- **AND** it clarifies that these integrations are optional for baseline Plane startup

### Requirement: Multi-signal observability scope and exposure model in docs
The documentation SHALL describe the expanded observability signal model and explicitly distinguish public versus internal-only endpoints for advanced Grafana OSS backends.

#### Scenario: User reads endpoint and observability sections
- **WHEN** a user reads root and module documentation
- **THEN** Grafana is documented as the public observability UI endpoint
- **AND** Prometheus, Loki, Tempo, and Pyroscope are documented as internal-only by default
- **AND** k6 usage is documented as an on-demand command path rather than a public service endpoint

#### Scenario: User reads observability signal matrix
- **WHEN** a user reviews observability docs
- **THEN** they can identify which component is responsible for metrics, logs, traces, profiles, and synthetic checks

### Requirement: Docling endpoint and integration behavior are documented in root docs
The system SHALL document the Docling endpoint, profile usage, and integration behavior for Step-CA, Keycloak, and observability in root README guidance.

#### Scenario: User reads endpoint list
- **WHEN** a user reviews the Endpoints section
- **THEN** `https://docling.<DEV_DOMAIN>` is listed with profile and security notes consistent with repository conventions

#### Scenario: User reviews integration behavior
- **WHEN** a user reads Docling setup instructions in root docs
- **THEN** documentation explains how Docling behaves with Step-CA, Keycloak, and observability enabled and disabled
- **AND** it clarifies that baseline Docling startup does not require optional integrations

