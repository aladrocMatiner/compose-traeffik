## MODIFIED Requirements
### Requirement: Multilingual LiteLLM service documentation
The system SHALL provide EN/SV/ES service README files for LiteLLM under `services/litellm/` using the standard multilingual README structure.

#### Scenario: Service README parity
- **WHEN** a user opens any `services/litellm/README*.md` variant
- **THEN** they can navigate to the other language variants via the language selector
- **AND** the page follows the standard service README anchor set used by `docs.manifest.json`

#### Scenario: Local inference and UI auth sections stay aligned
- **WHEN** LiteLLM local inference defaults and management UI credentials are documented
- **THEN** the EN/SV/ES LiteLLM service READMEs cover the same configuration variables and login flow concepts

### Requirement: Root README service list updates in all languages
The root EN/SV/ES README files SHALL list LiteLLM in the services overview and operations guidance as applicable.

#### Scenario: LiteLLM listed in root service inventory
- **WHEN** a user reads `README.md`, `README.sv.md`, or `README.es.md`
- **THEN** LiteLLM appears in the service list with a link to the corresponding service README

#### Scenario: Root endpoint/auth notes updated in all languages
- **WHEN** the LiteLLM management hostname and auth model are introduced
- **THEN** root README endpoint and operations sections are updated consistently across EN/SV/ES

#### Scenario: Standalone mode docs updated in all languages
- **WHEN** the standalone Traefik + LiteLLM mode is introduced
- **THEN** the root README operations guidance and LiteLLM service docs describe the standalone mode consistently across EN/SV/ES
