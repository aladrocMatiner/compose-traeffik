## ADDED Requirements

### Requirement: Playbook `system_bootstrap` orchestrates baseline host bootstrap
The system SHALL provide a playbook `system_bootstrap` under `deployment/ansible/playbooks` that runs the baseline bootstrap flow using existing deployment roles.

#### Scenario: Operator runs bootstrap entrypoint
- **WHEN** an operator runs `system_bootstrap`
- **THEN** the playbook applies `system_update` and `docker_git` in the same execution
- **AND** the host ends with updated packages plus Docker and Git baseline installed

### Requirement: `system_bootstrap` enforces role execution order
The system SHALL execute `system_update` before `docker_git` in `system_bootstrap`.

#### Scenario: Ordered role execution
- **WHEN** `system_bootstrap` is interpreted by Ansible
- **THEN** `system_update` is evaluated first
- **AND** `docker_git` is evaluated only after `system_update`

