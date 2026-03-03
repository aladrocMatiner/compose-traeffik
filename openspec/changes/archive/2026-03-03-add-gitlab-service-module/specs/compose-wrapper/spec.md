## MODIFIED Requirements

### Requirement: Functional ps target
The system SHALL provide working service lifecycle and test targets that use the standard compose wrapper, including service-specific targets for modular services such as GitLab.

#### Scenario: make ps
- **WHEN** a user runs `make ps`
- **THEN** the command executes successfully and lists services

#### Scenario: GitLab lifecycle and test targets
- **WHEN** a user runs `make gitlab-up`, `make gitlab-down`, `make gitlab-logs`, `make gitlab-status`, or `make test-gitlab`
- **THEN** the target executes successfully using the standard compose wrapper and repository test runner conventions
- **AND** `make help` documents the target names and purpose
