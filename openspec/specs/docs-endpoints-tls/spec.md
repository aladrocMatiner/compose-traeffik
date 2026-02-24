# docs-endpoints-tls Specification

## Purpose
TBD - created by archiving change update-readme-endpoints-tls-guides. Update Purpose after archive.
## Requirements
### Requirement: README endpoints and quickstart
The system SHALL document all real endpoints, including the DNS UI endpoint, and a self-signed quickstart in the root README files.

#### Scenario: Endpoint listing
- **WHEN** a user reads the Endpoints section
- **THEN** each endpoint includes hostname, URL, profile enablement, and security notes based on repo configuration
- **AND** the DNS UI endpoint `https://dns.${BASE_DOMAIN}` is listed with its `dns` profile note

#### Scenario: Self-signed quickstart
- **WHEN** a user follows the Quick start (Self-signed TLS)
- **THEN** they can complete setup using existing Make targets and scripts

### Requirement: TLS guides under docs/
The system SHALL provide complete TLS setup guides for Mode A/B/C under `docs/` with prerequisites, steps, expected result, verification, common pitfalls, and troubleshooting.

#### Scenario: Guide completeness
- **WHEN** a user reads any TLS guide
- **THEN** it includes the required sections and uses repo-accurate commands and paths

### Requirement: Root docs endpoint coverage for LiteLLM
The root multilingual READMEs SHALL document the LiteLLM endpoint, profile name, and authentication expectations.

#### Scenario: Endpoint listed in root README
- **WHEN** a user reads `README.md` (or a translated root README)
- **THEN** the LiteLLM endpoint `https://llm.${DEV_DOMAIN}` (or hostname override pattern) is listed with profile `litellm`
- **AND** the entry notes that LiteLLM API authentication is required

### Requirement: ENDPOINTS integration guidance
Project documentation SHALL explain how LiteLLM integrates with `ENDPOINTS` for hosts and DNS tooling.

#### Scenario: Hosts and DNS mapping guidance
- **WHEN** a user enables the LiteLLM module and wants local hostname mapping automation
- **THEN** documentation explains when and how to add `llm` to `ENDPOINTS`

### Requirement: TLS mode compatibility documentation
LiteLLM documentation SHALL describe compatibility with the repository TLS modes and Traefik certificate handling conventions.

#### Scenario: TLS mode explanation
- **WHEN** a user reads LiteLLM service documentation
- **THEN** it explains that the service is exposed through Traefik and follows the shared TLS mode setup (Mode A/B/C) used by the stack

### Requirement: Verified request example in LiteLLM service docs
The LiteLLM service documentation SHALL include at least one verified request or health-check example for the pinned LiteLLM version.

#### Scenario: Authenticated verification example
- **WHEN** a user reads `services/litellm/README.md` (or translated variants)
- **THEN** they can find a curl example using the documented endpoint path and auth header format for the pinned version
- **AND** the docs explain the expected behavior when no provider key is configured

