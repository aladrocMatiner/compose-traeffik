## ADDED Requirements

### Requirement: DNS hardening runbook
The documentation SHALL include DNS hardening verification and rollback steps for BIND operations in this branch.

#### Scenario: Operator validates hardening after changes
- **WHEN** an operator updates BIND config or provisioning logic
- **THEN** documentation provides security verification commands for recursion, AXFR, and metadata checks
- **AND** documentation includes rollback steps to restore a known-safe DNS baseline

