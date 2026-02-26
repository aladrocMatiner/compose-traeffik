## ADDED Requirements

### Requirement: n8n endpoint and TLS mode documentation
The documentation SHALL list the n8n endpoint and describe its compatibility with the stack TLS modes used via Traefik.

#### Scenario: Root docs list n8n endpoint
- **WHEN** service endpoints are documented in root README files
- **THEN** `https://n8n.<DEV_DOMAIN>` is listed as an optional endpoint
- **AND** the n8n service page references Traefik TLS mode compatibility and optional step-ca trust for outbound calls when relevant
