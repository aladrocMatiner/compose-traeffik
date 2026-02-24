# docs-multilang Specification

## Purpose
TBD - created by archiving change refactor-multilang-docs. Update Purpose after archive.
## Requirements
### Requirement: Multilingual README system
The system SHALL provide EN/SV/ES root and per-service README files with a language selector linking to equivalent pages.

#### Scenario: Language selector parity
- **WHEN** a user opens any README page
- **THEN** they see links to the EN/SV/ES versions of that same page

### Requirement: Structural parity across languages
The system SHALL keep section structure and anchor IDs consistent across EN/SV/ES variants.

#### Scenario: Anchor consistency
- **WHEN** a user navigates between languages
- **THEN** equivalent sections use the same anchor IDs

### Requirement: Validation tooling
The system SHALL include a docs validation script and Makefile target to verify completeness and link correctness.

#### Scenario: Docs check
- **WHEN** `make docs-check` is executed
- **THEN** it fails on missing README variants, broken links, or selector mismatches

### Requirement: Multilingual LiteLLM service documentation
The system SHALL provide EN/SV/ES service README files for LiteLLM under `services/litellm/` using the standard multilingual README structure.

#### Scenario: Service README parity
- **WHEN** a user opens any `services/litellm/README*.md` variant
- **THEN** they can navigate to the other language variants via the language selector
- **AND** the page follows the standard service README anchor set used by `docs.manifest.json`

### Requirement: Root README service list updates in all languages
The root EN/SV/ES README files SHALL list LiteLLM in the services overview and operations guidance as applicable.

#### Scenario: LiteLLM listed in root service inventory
- **WHEN** a user reads `README.md`, `README.sv.md`, or `README.es.md`
- **THEN** LiteLLM appears in the service list with a link to the corresponding service README

### Requirement: Docs manifest registration for LiteLLM
The docs manifest SHALL include the LiteLLM service so documentation validation tooling can enforce parity.

#### Scenario: docs.manifest entry exists
- **WHEN** `make docs-check` validates service pages
- **THEN** `docs.manifest.json` contains a `litellm` service entry with titles for EN/SV/ES

