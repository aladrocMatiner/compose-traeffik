## ADDED Requirements

### Requirement: n8n bootstrap randomizes required application and database secrets
The bootstrap workflow SHALL randomize required n8n and bundled database secrets for the n8n module instead of leaving placeholder or static default values in the generated local configuration.

#### Scenario: Developer bootstraps before enabling n8n
- **WHEN** a developer runs `make bootstrap` (or the equivalent env generation workflow) before using the `n8n` profile
- **THEN** the generated `.env` contains concrete randomized values for required n8n and database secrets (including the encryption key)
- **AND** the generated values are suitable for immediate local use without manual secret editing

### Requirement: n8n bootstrap provisions local generated assets
The bootstrap workflow SHALL create any required local generated assets/config files for the n8n module defaults so preflight checks and compose parsing succeed without manual file creation.

#### Scenario: Bootstrap prepares local n8n assets
- **WHEN** bootstrap completes with the n8n module defaults present in `.env`
- **THEN** any required local generated assets for n8n exist in the expected gitignored paths
- **AND** subsequent compose/preflight commands do not fail because those files are missing
