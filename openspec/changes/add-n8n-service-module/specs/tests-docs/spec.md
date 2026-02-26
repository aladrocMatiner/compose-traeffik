## ADDED Requirements

### Requirement: n8n smoke suite documentation
The tests documentation SHALL describe the n8n static smoke suite and when runtime validation is required separately.

#### Scenario: Tests inventory lists n8n static smoke tests
- **WHEN** a developer reads `tests/README.md`
- **THEN** the n8n smoke scripts are listed with purpose and prerequisites
- **AND** runtime validation for n8n is documented separately from static smoke tests
