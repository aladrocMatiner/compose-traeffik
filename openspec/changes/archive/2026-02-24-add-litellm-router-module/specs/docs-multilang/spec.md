## ADDED Requirements
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
