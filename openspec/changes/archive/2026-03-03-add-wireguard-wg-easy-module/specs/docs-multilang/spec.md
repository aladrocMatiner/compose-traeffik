## MODIFIED Requirements

### Requirement: Multilingual README system
The system SHALL provide EN/SV/ES root and per-service README files with a language selector linking to equivalent pages. When a new service module is added (such as the WireGuard module), the corresponding EN/SV/ES service README variants SHALL be added under `services/<service>/`.

#### Scenario: Language selector parity
- **WHEN** a user opens any README page
- **THEN** they see links to the EN/SV/ES versions of that same page

#### Scenario: New service adds multilingual pages
- **WHEN** a new service module (for example `services/wg-easy/`) is introduced
- **THEN** `README.md`, `README.sv.md`, and `README.es.md` exist for that service
- **AND** they participate in the same multilingual navigation pattern as existing services

### Requirement: Structural parity across languages
The system SHALL keep section structure and anchor IDs consistent across EN/SV/ES variants.

#### Scenario: Anchor consistency
- **WHEN** a user navigates between languages
- **THEN** equivalent sections use the same anchor IDs

### Requirement: Validation tooling
The system SHALL include a docs validation script and Makefile target to verify completeness and link correctness, including entries declared in `docs.manifest.json`.

#### Scenario: Docs check
- **WHEN** `make docs-check` is executed
- **THEN** it fails on missing README variants, broken links, or selector mismatches
- **AND** it validates any newly registered service page entry (such as `wg-easy`) in the documentation manifest

