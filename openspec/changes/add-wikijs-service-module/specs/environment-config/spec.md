## ADDED Requirements

### Requirement: Wiki.js environment defaults are safe and bootstrap-ready
The repository SHALL define `.env.example` defaults for the Wiki.js module that are safe for planning and local setup while allowing bootstrap to generate concrete runtime secrets and local assets.

#### Scenario: Developer copies `.env.example` before bootstrap
- **WHEN** a developer inspects or copies `.env.example`
- **THEN** Wiki.js variables include a default hostname of `wiki` for the public route `https://wiki.<DEV_DOMAIN>`
- **AND** secret-bearing values are represented as bootstrap-managed inputs rather than production-ready hardcoded secrets

#### Scenario: Bootstrapped env preserves Wiki.js route naming
- **WHEN** a developer runs bootstrap and then enables the `wikijs` profile
- **THEN** the generated configuration preserves `wiki.<DEV_DOMAIN>` as the default public route unless the user explicitly overrides the hostname variable
