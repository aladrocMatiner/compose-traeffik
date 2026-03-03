## ADDED Requirements

### Requirement: QEMU target supports AlmaLinux 9 cloud image profile
The `vm-provisioning` workflow SHALL support selecting a `almalinux9` OS profile for `target=qemu` (local `libvirt`) using a documented and pinned AlmaLinux 9 cloud image with `cloud-init`-compatible defaults.

#### Scenario: Operator provisions AlmaLinux 9 on qemu
- **WHEN** an operator runs the qemu provisioning workflow with the `almalinux9` OS profile and valid networking/SSH inputs
- **THEN** the system provisions a VM on local `libvirt` using the configured AlmaLinux 9 cloud image
- **AND** cloud-init configures hostname, fixed IP, and SSH access according to the shared provisioning contract

#### Scenario: Profile prerequisites are not met
- **WHEN** the `almalinux9` profile image metadata is missing, invalid, or incompatible with the qemu provisioning workflow
- **THEN** the provisioning workflow exits non-zero with a clear error describing the missing or invalid profile prerequisites
- **AND** no partially configured host is reported as ready
