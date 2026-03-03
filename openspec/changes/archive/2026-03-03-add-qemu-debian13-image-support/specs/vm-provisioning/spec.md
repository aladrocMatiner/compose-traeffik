## ADDED Requirements

### Requirement: QEMU target supports Debian 13 cloud image profile
The `vm-provisioning` workflow SHALL support selecting a `debian13` OS profile for `target=qemu` (local `libvirt`) using a documented and pinned Debian 13 cloud image that is compatible with `cloud-init` and the shared provisioning contract (hostname, fixed IP, SSH).

#### Scenario: Operator provisions Debian 13 on qemu
- **WHEN** an operator runs the qemu provisioning workflow with the `debian13` OS profile and valid networking/SSH inputs
- **THEN** the system provisions a VM on local `libvirt` using the configured Debian 13 cloud image
- **AND** cloud-init configures hostname, fixed IP, and SSH access according to the shared provisioning contract

#### Scenario: Debian 13 profile metadata is missing or invalid
- **WHEN** the `debian13` profile image metadata (such as image URL/path, version pin, or checksum policy) is missing, invalid, or incompatible with the qemu provisioning workflow
- **THEN** the provisioning workflow exits non-zero with a clear error describing the invalid or missing Debian 13 profile prerequisites
- **AND** no partially configured host is reported as ready

#### Scenario: Unsupported profile parameters are provided
- **WHEN** an operator provides parameters that do not apply to the `debian13` profile (for example `init=` values reserved for Gentoo variants)
- **THEN** the provisioning workflow exits non-zero with a clear validation error describing the unsupported parameter usage
- **AND** the error message preserves the supported usage for the selected OS profile
