## ADDED Requirements
### Requirement: Full-mode hosts include DNS endpoint
When the full bootstrap mode is used, the generated hosts entries SHALL include the DNS endpoint.

#### Scenario: Full bootstrap hosts generation
- **WHEN** a user runs `make bootstrap-full` and then `make hosts-generate`
- **THEN** the generated hosts block includes `dns.${BASE_DOMAIN}`

## MODIFIED Requirements
### Requirement: Quickstart env generation options
The quickstart documentation SHALL mention the `--mode` option for env generation so users understand the production vs full paths.

#### Scenario: Quickstart mentions modes
- **WHEN** a user reads the quickstart section
- **THEN** they see `--mode=prod` and `--mode=full` guidance alongside bootstrap commands
