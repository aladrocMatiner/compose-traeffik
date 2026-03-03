## ADDED Requirements

### Requirement: QEMU target supports Ubuntu LTS versioned cloud image profiles
The `vm-provisioning` workflow SHALL support selecting `ubuntu20.04`, `ubuntu22.04`, and `ubuntu24.04` OS profiles for `target=qemu` (local `libvirt`) using documented and pinned Ubuntu cloud image metadata per profile.

#### Scenario: Operator provisions Ubuntu 22.04 on qemu
- **WHEN** an operator runs the qemu provisioning workflow with `--os ubuntu22.04` and valid networking/SSH inputs
- **THEN** the system provisions a VM on local `libvirt` using the configured Ubuntu 22.04 cloud image profile
- **AND** cloud-init configures hostname, fixed IP, and SSH access according to the shared provisioning contract

#### Scenario: Profile metadata for selected Ubuntu LTS is invalid
- **WHEN** selected Ubuntu LTS image metadata is missing, invalid, or checksum validation fails
- **THEN** the provisioning workflow exits non-zero with a clear profile metadata error
- **AND** no partially configured host is reported as ready

### Requirement: Legacy `ubuntu` selector remains backward-compatible as deterministic alias
The `vm-provisioning` workflow SHALL keep `ubuntu` as a backward-compatible selector and SHALL resolve it deterministically to the `ubuntu24.04` profile.

#### Scenario: Operator uses legacy selector `ubuntu`
- **WHEN** an operator runs provisioning commands with `--os ubuntu`
- **THEN** the workflow resolves the request to the same image/profile contract as `ubuntu24.04`
- **AND** provisioning behavior remains compatible with existing automation that already uses `ubuntu`

### Requirement: Host bootstrap and readiness flows accept Ubuntu LTS versioned selectors
The host bootstrap and readiness scripts SHALL accept `ubuntu20.04`, `ubuntu22.04`, and `ubuntu24.04` selectors and SHALL apply the existing Ubuntu apt-based Docker bootstrap path for those selectors.

#### Scenario: Operator runs host bootstrap for Ubuntu 20.04 selector
- **WHEN** an operator runs host bootstrap/check flows with `--os ubuntu20.04`
- **THEN** selector validation passes
- **AND** Docker bootstrap/readiness checks follow the Ubuntu-family apt workflow
