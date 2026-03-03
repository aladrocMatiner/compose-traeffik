## ADDED Requirements

### Requirement: Role `system_update` updates packages across supported deployment operating systems
The system SHALL provide an Ansible role `system_update` under `deployment/ansible` that updates package metadata and applies system package updates for all deployment OS selectors currently supported by the repository.

#### Scenario: Operator runs `system_update` on a supported selector
- **GIVEN** a host mapped to one of `ubuntu`, `debian12`, `debian13`, `debian`, `gentoo`, `opensuse-leap`, `almalinux9`, `rockylinux9`, `fedora-cloud`
- **WHEN** the `system_update` role is executed
- **THEN** the role uses the appropriate package manager flow for that OS family
- **AND** package metadata is refreshed before updates are applied

#### Scenario: Unsupported platform is targeted
- **WHEN** the `system_update` role is executed on a platform outside the supported selector set
- **THEN** the role fails fast with a clear unsupported-platform message
- **AND** no partial package update is attempted

### Requirement: Role `docker_git` installs Docker and Git across supported deployment operating systems
The system SHALL provide an Ansible role `docker_git` under `deployment/ansible` that installs Docker and Git for all deployment OS selectors currently supported by the repository.

#### Scenario: Operator bootstraps tooling on a supported selector
- **GIVEN** a host mapped to one of `ubuntu`, `debian12`, `debian13`, `debian`, `gentoo`, `opensuse-leap`, `almalinux9`, `rockylinux9`, `fedora-cloud`
- **WHEN** the `docker_git` role is executed
- **THEN** `git` and Docker packages are installed using distro-appropriate package names and repositories
- **AND** the Docker service is enabled and started where service management applies

#### Scenario: Role is re-run on an already provisioned host
- **WHEN** the `docker_git` role is executed on a host where required packages are already present
- **THEN** the role completes successfully without unnecessary changes
- **AND** the resulting state for `git` and Docker availability remains consistent
