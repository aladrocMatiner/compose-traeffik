## ADDED Requirements

### Requirement: Smoke test inventory covers service observability wiring checks
The standard smoke test inventory SHALL include observability wiring smoke tests for services that introduce observability toggles or labels.

#### Scenario: Contributor reviews service observability tests
- **WHEN** a contributor scans the smoke test inventory table
- **THEN** they can see which scripts validate observability wiring for each applicable service
