## ADDED Requirements

### Requirement: n8n module follows service layout conventions
The repository SHALL place the n8n service module under `services/n8n/` using the same documentation and generated-artifact layout conventions as other service modules.

#### Scenario: n8n module layout is discoverable
- **WHEN** a developer inspects `services/n8n/`
- **THEN** the module includes a compose fragment, multilingual README files, and a gitignored rendered-artifacts directory path used by bootstrap/render scripts
