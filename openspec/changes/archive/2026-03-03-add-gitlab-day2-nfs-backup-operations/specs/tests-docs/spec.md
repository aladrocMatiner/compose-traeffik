## MODIFIED Requirements

### Requirement: Smoke test documentation
The system SHALL document smoke tests in `tests/README.md` with purpose, run instructions, inventory, configuration, expected output, and troubleshooting. GitLab day-2 safety and NFS guardrail tests SHALL be documented when the GitLab day-2 module is added.

#### Scenario: Documentation completeness
- **WHEN** a user reads `tests/README.md`
- **THEN** they can understand what each test validates and how to interpret failures

#### Scenario: GitLab day-2 tests documented
- **WHEN** GitLab day-2 operations are available
- **THEN** `tests/README.md` documents the backup/restore/upgrade/NFS guardrail smoke tests and their prerequisites
