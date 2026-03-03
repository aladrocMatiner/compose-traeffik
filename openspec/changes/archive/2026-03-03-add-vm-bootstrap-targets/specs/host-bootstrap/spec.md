## ADDED Requirements

### Requirement: Scripted Docker host bootstrap on provisioned Ubuntu VMs
The system SHALL provide a script-driven host bootstrap workflow that connects over SSH to provisioned Ubuntu VMs and installs Docker Engine plus the Docker Compose plugin.

#### Scenario: Bootstrap a newly provisioned host
- **WHEN** an operator runs the host bootstrap workflow against a reachable Ubuntu VM created by the provisioning workflow
- **THEN** Docker Engine is installed on the host
- **AND** the Docker Compose plugin is installed and available to the target SSH user

### Requirement: Bootstrap verification and operator feedback
The host bootstrap workflow SHALL verify SSH reachability and Docker readiness, and SHALL emit clear success or failure output for each host.

#### Scenario: Readiness checks pass
- **WHEN** bootstrap completes successfully for a host
- **THEN** the workflow verifies `docker --version` and `docker compose version`
- **AND** the operator receives a clear indication that the host is ready for later deployment steps

#### Scenario: SSH connectivity fails
- **WHEN** the target host is not reachable via SSH with the provided credentials
- **THEN** the workflow exits non-zero with a clear error identifying the host
- **AND** no deployment-specific actions are attempted on that host

### Requirement: Bootstrap workflow remains separate from application deployment
The host bootstrap workflow SHALL stop at preparing the host for future configuration/deployment automation and SHALL NOT start project-specific `docker compose` services in this phase.

#### Scenario: Bootstrap phase completes
- **WHEN** an operator runs the host bootstrap workflow for one or more hosts
- **THEN** the workflow finishes after host readiness checks
- **AND** no project stack containers are started as part of that bootstrap execution

### Requirement: Bootstrap inputs support future Ansible handoff
The host bootstrap workflow SHALL accept host connection data in a machine-readable form that can be produced by Terraform outputs, while also allowing direct operator-provided host parameters for debugging.

#### Scenario: Bootstrap uses Terraform-generated host metadata
- **WHEN** an operator provides host connection data generated from Terraform outputs
- **THEN** the bootstrap workflow connects to the listed hosts without requiring provider-specific parsing logic in the bootstrap step
- **AND** the same workflow can later be replaced or wrapped by Ansible without changing the provisioning output contract
