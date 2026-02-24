## MODIFIED Requirements
### Requirement: Root docs endpoint coverage for LiteLLM
The root multilingual READMEs SHALL document the LiteLLM endpoint, profile name, and authentication expectations.

#### Scenario: Endpoint listed in root README
- **WHEN** a user reads `README.md` (or a translated root README)
- **THEN** the LiteLLM endpoint `https://llm.${DEV_DOMAIN}` (or hostname override pattern) is listed with profile `litellm`
- **AND** the entry notes that LiteLLM API authentication is required

## ADDED Requirements
### Requirement: LiteLLM management hostname documentation
The root and LiteLLM service documentation SHALL describe the dedicated LiteLLM management hostname and its access controls.

#### Scenario: Management hostname listed
- **WHEN** a user reads the root README or `services/litellm/README*.md`
- **THEN** the LiteLLM management hostname pattern (for example `https://llm-admin.${DEV_DOMAIN}`) is documented
- **AND** the documentation distinguishes UI BasicAuth credentials from the LiteLLM API master key

### Requirement: Local inference default behavior documentation
LiteLLM documentation SHALL explain the default local inference backend configuration and how to override it.

#### Scenario: Local backend defaults documented
- **WHEN** a user reads `services/litellm/README*.md`
- **THEN** they can see the default local inference backend endpoint/model env vars
- **AND** they can override the endpoint/model without editing the committed config template

### Requirement: Hosts and DNS endpoint mapping guidance for LiteLLM admin host
Project documentation SHALL explain how `ENDPOINTS` automation applies to both LiteLLM API and admin hostnames when enabled.

#### Scenario: ENDPOINTS guidance includes admin host
- **WHEN** a user enables LiteLLM and uses hosts/DNS automation
- **THEN** documentation explains whether to add `llm`, `llm-admin`, or both to `ENDPOINTS` based on their chosen hostnames

### Requirement: Standalone LiteLLM edge mode documentation
Project documentation SHALL describe a standalone `Traefik + LiteLLM` mode and its external dependencies.

#### Scenario: Standalone mode command and scope documented
- **WHEN** a user reads root or LiteLLM service documentation
- **THEN** they can find the standalone mode commands
- **AND** the docs state which local containers are intentionally not started in that mode

### Requirement: Remote step-ca TLS guidance for standalone mode
Project documentation SHALL explain how standalone LiteLLM mode can obtain TLS certificates via Traefik from a remote `step-ca` ACME endpoint.

#### Scenario: Remote step-ca setup guidance
- **WHEN** a user wants LAN TLS for LiteLLM standalone mode with an external `step-ca`
- **THEN** the docs explain the relevant env settings (including `STEP_CA_CA_SERVER`) and client trust prerequisites
