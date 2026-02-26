## ADDED Requirements

### Requirement: n8n docs maintain multilingual parity
The repository SHALL add n8n service documentation references and endpoint notes in English, Swedish, and Spanish root docs, plus multilingual service pages for the n8n module.

#### Scenario: n8n docs are available in all supported languages
- **WHEN** the n8n module is added to the repository docs
- **THEN** `README.md`, `README.sv.md`, and `README.es.md` reference the n8n service and endpoint
- **AND** `services/n8n/README.md`, `services/n8n/README.sv.md`, and `services/n8n/README.es.md` exist with the standard service-page structure
