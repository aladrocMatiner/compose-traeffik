## ADDED Requirements

### Requirement: Multi-target VM provisioning for deployment hosts
The system SHALL provide Terraform-based VM provisioning for deployment hosts with at least two targets: local QEMU via `libvirt` and remote `Proxmox`.

#### Scenario: Provision a VM on libvirt
- **WHEN** an operator runs the provisioning workflow with target `libvirt` and valid target inputs
- **THEN** Terraform creates a VM on the local `libvirt` environment
- **AND** the resulting host is initialized with cloud-init data for bootstrap

#### Scenario: Provision a VM on Proxmox
- **WHEN** an operator runs the provisioning workflow with target `proxmox` and valid target inputs plus Proxmox credentials
- **THEN** Terraform creates or clones a VM on the remote Proxmox environment
- **AND** the resulting host is initialized with cloud-init data for bootstrap

### Requirement: Shared VM input contract with target-specific extensions
The provisioning workflow SHALL define a shared input contract for VM identity, Ubuntu image source, static networking, and SSH access, while allowing additional target-specific parameters without changing the shared contract semantics.

#### Scenario: Same host definition is portable across targets
- **WHEN** an operator defines hostname, fixed IP, gateway, DNS servers, SSH user, SSH public key, and Ubuntu image inputs
- **THEN** the same host definition fields can be applied to both `libvirt` and `proxmox`
- **AND** only target-specific provider fields need to vary

### Requirement: Ubuntu cloud-init bootstrap for fixed IP and SSH
The provisioning workflow SHALL use Ubuntu cloud images and `cloud-init` to configure hostname, fixed IP networking, and SSH access before any post-provision host bootstrap scripts run.

#### Scenario: Host becomes reachable after first boot
- **WHEN** a VM boots for the first time after provisioning
- **THEN** cloud-init applies the configured hostname and static network settings
- **AND** the configured SSH user and authorized key allow remote login at the declared fixed IP

### Requirement: Deterministic outputs for downstream automation
The provisioning workflow SHALL expose machine-readable outputs that include at least target name, hostname, fixed IP, and SSH user so later automation can consume them without provider-specific parsing.

#### Scenario: Operator requests Terraform outputs
- **WHEN** an operator runs `terraform output -json` after a successful apply
- **THEN** the output includes a stable host metadata structure with the core fields required for post-provision automation
- **AND** the same core fields are present for both `libvirt` and `proxmox` targets
