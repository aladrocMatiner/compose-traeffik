## ADDED Requirements

### Requirement: n8n scripts are documented in script inventory
The scripts documentation SHALL include the n8n bootstrap/render helper scripts and their expected inputs/outputs.

#### Scenario: Scripts inventory lists n8n helpers
- **WHEN** a developer reads `scripts/README.md`
- **THEN** the n8n bootstrap/render scripts are listed with purpose, typical usage, required env vars, and side effects
