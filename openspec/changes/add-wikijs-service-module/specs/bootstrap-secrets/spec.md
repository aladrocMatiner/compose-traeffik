## ADDED Requirements

### Requirement: Wiki.js bootstrap randomizes required application and database secrets
The bootstrap workflow SHALL randomize required Wiki.js and bundled database secrets for the Wiki.js module instead of leaving placeholder or static default values in the generated local configuration.

#### Scenario: Developer bootstraps before enabling Wiki.js
- **WHEN** a developer runs `make bootstrap` (or the equivalent env generation workflow) before using the `wikijs` profile
- **THEN** the generated `.env` contains concrete randomized values for required Wiki.js and database secrets
- **AND** the generated values are suitable for immediate local use without manual secret editing

### Requirement: Wiki.js bootstrap provisions local generated assets
The bootstrap workflow SHALL create any required local generated assets/config files for the Wiki.js module defaults so preflight checks and compose parsing succeed without manual file creation.

#### Scenario: Bootstrap prepares local Wiki.js assets
- **WHEN** bootstrap completes with the Wiki.js module defaults present in `.env`
- **THEN** any required local generated assets for Wiki.js (for example rendered config placeholders or module-specific local files) exist in the expected gitignored paths
- **AND** subsequent compose/preflight commands do not fail because those files are missing
