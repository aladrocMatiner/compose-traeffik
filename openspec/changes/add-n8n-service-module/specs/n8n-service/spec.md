## ADDED Requirements

### Requirement: n8n service module behind Traefik
The system SHALL provide an optional n8n service module under `services/n8n/` that runs behind Traefik with HTTPS routing and profile-gated lifecycle commands.

#### Scenario: n8n profile is enabled
- **WHEN** the operator enables the `n8n` profile or runs n8n lifecycle commands
- **THEN** Docker Compose includes the n8n application and its required database dependency service(s)
- **AND** Traefik routes `https://n8n.<DEV_DOMAIN>` to the n8n service
- **AND** the module remains disabled during default stack runs unless the profile is explicitly enabled

### Requirement: n8n bootstrap rendering and optional integration runbooks
The system SHALL provide a bootstrap/render workflow that generates deterministic n8n runtime configuration artifacts and optional integration runbooks from `.env` values.

#### Scenario: Bootstrap renders n8n config artifacts
- **WHEN** the operator runs `make n8n-bootstrap`
- **THEN** the system writes generated artifacts under a gitignored `services/n8n/rendered/` directory
- **AND** it renders the inputs needed for the planned n8n runtime configuration (including public/webhook URL settings)
- **AND** it renders optional Keycloak and observability guidance artifacts when those integrations are enabled

### Requirement: Optional Keycloak, observability, and step-ca compatibility hooks
The n8n module SHALL define optional hooks for Keycloak integration, observability, and step-ca compatibility with safe defaults that keep all integrations disabled unless explicitly enabled.

#### Scenario: Optional integrations remain disabled by default
- **WHEN** a developer boots the stack without enabling n8n optional integration toggles
- **THEN** n8n runs without Keycloak-specific configuration hooks and without optional observability hooks
- **AND** the module remains compatible with the stack's selected Traefik TLS mode without exposing additional admin or metrics endpoints by default

#### Scenario: Observability uses the full upstream-supported path when available
- **WHEN** upstream verification confirms a documented/installable observability path for the target n8n version
- **THEN** the module implements that full supported path behind explicit optional toggles
- **AND** the docs and guardrails reflect the chosen observability mode and required inputs

#### Scenario: Keycloak uses internal PKI via step-ca (planned support)
- **WHEN** a developer enables n8n + Keycloak and the Keycloak issuer uses a step-ca-signed certificate
- **THEN** the module documents and validates the required internal CA trust configuration for n8n outbound HTTPS calls
- **AND** the inbound n8n route continues to use the stack's Traefik TLS mode selection
