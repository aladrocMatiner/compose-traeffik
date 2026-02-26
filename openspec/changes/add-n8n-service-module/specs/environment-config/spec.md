## ADDED Requirements

### Requirement: n8n environment defaults are safe and bootstrap-ready
The repository SHALL define `.env.example` defaults for the n8n module that are safe for planning and local setup while allowing bootstrap to generate concrete runtime secrets and local assets.

#### Scenario: Developer copies `.env.example` before bootstrap
- **WHEN** a developer inspects or copies `.env.example`
- **THEN** n8n variables include a default hostname of `n8n` for the public route `https://n8n.<DEV_DOMAIN>`
- **AND** secret-bearing values are represented as bootstrap-managed inputs rather than production-ready hardcoded secrets

#### Scenario: Bootstrapped env preserves n8n route naming
- **WHEN** a developer runs bootstrap and then enables the `n8n` profile
- **THEN** the generated configuration preserves `n8n.<DEV_DOMAIN>` as the default public route unless the user explicitly overrides the hostname variable
