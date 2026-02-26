## ADDED Requirements

### Requirement: service-specific n8n static smoke suite
The repository SHALL provide a service-specific static smoke suite for the n8n module that can run without starting n8n containers.

#### Scenario: n8n static smoke suite runs via Make target
- **WHEN** a developer runs `make test-n8n`
- **THEN** the repository executes n8n static smoke tests covering make-target wiring, compose wiring, guardrails, and bootstrap/render output checks
