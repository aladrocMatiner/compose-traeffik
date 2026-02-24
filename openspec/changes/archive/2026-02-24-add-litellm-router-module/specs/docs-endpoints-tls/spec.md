## ADDED Requirements
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
