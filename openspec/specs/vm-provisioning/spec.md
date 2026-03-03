# vm-provisioning Specification

## Purpose
TBD - created by archiving change add-ubuntu-lts-os-selectors. Update Purpose after archive.
## Requirements
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

### Requirement: QEMU target supports Rocky Linux 9 cloud image profile
The `vm-provisioning` workflow SHALL support selecting a `rockylinux9` OS profile for `target=qemu` (local `libvirt`) using a documented and pinned Rocky Linux 9 cloud image with `cloud-init`-compatible defaults.

#### Scenario: Operator provisions Rocky Linux 9 on qemu
- **WHEN** an operator runs the qemu provisioning workflow with the `rockylinux9` OS profile and valid networking/SSH inputs
- **THEN** the system provisions a VM on local `libvirt` using the configured Rocky Linux 9 cloud image
- **AND** cloud-init configures hostname, fixed IP, and SSH access according to the shared provisioning contract

#### Scenario: Profile prerequisites are not met
- **WHEN** the `rockylinux9` profile image metadata is missing, invalid, or incompatible with the qemu provisioning workflow
- **THEN** the provisioning workflow exits non-zero with a clear error describing the missing or invalid profile prerequisites
- **AND** no partially configured host is reported as ready

### Requirement: QEMU target supports qualified Gentoo (Experimental) image profiles with init selection
The `vm-provisioning` workflow SHALL support selecting a `gentoo` OS profile for `target=qemu` (local `libvirt`) with an init-system selector `init=<openrc|systemd>`, where `openrc` is the default when `init` is omitted. Provisioning is allowed only when the selected Gentoo experimental image profile variant is qualified with documented image metadata (including pinning and integrity information) and `cloud-init`-compatible provisioning defaults for the shared contract (hostname, fixed IP, SSH access). Qualification and support level MUST be tracked per init variant so `openrc` and `systemd` can progress independently without changing the Gentoo default.

#### Scenario: Operator provisions Gentoo on qemu without specifying init
- **WHEN** an operator runs the qemu provisioning workflow with `os=gentoo`, valid networking/SSH inputs, and no explicit `init` value
- **THEN** the workflow resolves the Gentoo init variant to `openrc`
- **AND** the system provisions a VM using the qualified Gentoo `openrc` image profile manifest
- **AND** cloud-init configures hostname, fixed IP, and SSH access according to the shared provisioning contract

#### Scenario: Operator provisions Gentoo with explicit systemd init override
- **WHEN** an operator runs the qemu provisioning workflow with `os=gentoo` and `init=systemd`
- **THEN** the workflow uses the qualified Gentoo `systemd` image profile manifest for qemu provisioning
- **AND** the workflow applies the same shared provisioning contract (hostname, fixed IP, SSH access) when the `systemd` variant is qualified for that workflow step
- **AND** the workflow clearly indicates that `openrc` remains the default Gentoo baseline when relevant to readiness or support level messaging

#### Scenario: Operator selects systemd variant before it reaches the requested gate
- **WHEN** an operator runs the qemu provisioning workflow with `os=gentoo` and `init=systemd` but the `systemd` profile metadata does not declare support for the requested workflow step/gate
- **THEN** the workflow fails before claiming readiness
- **AND** the error message identifies that the `systemd` variant exists but is not yet qualified for that specific gate

#### Scenario: Gentoo image profile variant is not yet qualified
- **WHEN** an operator selects `os=gentoo` with an init variant whose required Gentoo image profile metadata is missing, invalid, or marked unqualified for qemu provisioning
- **THEN** the provisioning workflow exits non-zero with a clear error describing the missing or invalid qualification prerequisites
- **AND** no partially configured host is reported as ready

### Requirement: Gentoo init selector MUST be validated and scoped to Gentoo
The system SHALL validate Gentoo init selection inputs and treat `init` as a Gentoo-specific selector with accepted values `openrc` and `systemd`.

#### Scenario: Operator uses invalid init value for Gentoo
- **WHEN** an operator runs the qemu provisioning workflow with `os=gentoo` and an unsupported init value
- **THEN** the workflow fails before provisioning with a clear error listing accepted values (`openrc`, `systemd`)

#### Scenario: Operator passes init selector for a non-Gentoo OS
- **WHEN** an operator runs the provisioning workflow with `os` set to a non-Gentoo distro and also passes `init=...`
- **THEN** the workflow fails before provisioning with a clear error stating that `init` is only valid for `os=gentoo`

### Requirement: Gentoo experimental profile MUST declare compatibility and limitations
The system SHALL document and validate the compatibility attributes of a `gentoo` qemu image profile, including at minimum the image source/pinning metadata, init system variant, `cloud-init` support status, whether the profile is eligible for the `OpenRC` default baseline, and any explicitly unsupported steps (such as Docker bootstrap parity when not yet approved).

#### Scenario: Operator selects an unsupported Gentoo variant for the requested workflow step
- **WHEN** an operator selects a Gentoo experimental variant or manifest whose declared compatibility attributes do not satisfy the requested workflow step
- **THEN** the system fails before claiming readiness for that step
- **AND** the error message identifies the unsupported attribute (for example init system variant, missing qualification, or missing Docker parity)

#### Scenario: Operator reviews Gentoo experimental profile metadata
- **WHEN** an operator inspects the Gentoo experimental profile definition used by qemu provisioning
- **THEN** the profile metadata includes a pinned image reference (or project-prepared image reference), integrity verification data, the declared init system, default-baseline eligibility status, and declared compatibility/limitations for provisioning readiness

### Requirement: QEMU target supports openSUSE Leap cloud image profile
The `vm-provisioning` workflow SHALL support selecting a `opensuse-leap` OS profile for `target=qemu` (local `libvirt`) using a documented and pinned openSUSE Leap cloud image with `cloud-init`-compatible defaults.

#### Scenario: Operator provisions openSUSE Leap on qemu
- **WHEN** an operator runs the qemu provisioning workflow with the `opensuse-leap` OS profile and valid networking/SSH inputs
- **THEN** the system provisions a VM on local `libvirt` using the configured openSUSE Leap cloud image
- **AND** cloud-init configures hostname, fixed IP, and SSH access according to the shared provisioning contract

#### Scenario: Profile prerequisites are not met
- **WHEN** the `opensuse-leap` profile image metadata is missing, invalid, or incompatible with the qemu provisioning workflow
- **THEN** the provisioning workflow exits non-zero with a clear error describing the missing or invalid profile prerequisites
- **AND** no partially configured host is reported as ready

### Requirement: QEMU target supports Debian 12 cloud image profile
The `vm-provisioning` workflow SHALL support selecting a `debian12` OS profile for `target=qemu` (local `libvirt`) using a documented and pinned official Debian cloud image with `cloud-init`-compatible defaults.

#### Scenario: Operator provisions Debian 12 on qemu
- **WHEN** an operator runs the qemu provisioning workflow with the `debian12` OS profile and valid networking/SSH inputs
- **THEN** the system provisions a VM on local `libvirt` using the configured Debian 12 cloud image
- **AND** cloud-init configures hostname, fixed IP, and SSH access according to the shared provisioning contract

#### Scenario: Profile prerequisites are not met
- **WHEN** the `debian12` profile image metadata is missing, invalid, or incompatible with the qemu provisioning workflow
- **THEN** the provisioning workflow exits non-zero with a clear error describing the missing or invalid profile prerequisites
- **AND** no partially configured host is reported as ready

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

### Requirement: QEMU target supports Fedora Cloud cloud image profile
The `vm-provisioning` workflow SHALL support selecting a `fedora-cloud` OS profile for `target=qemu` (local `libvirt`) using a documented and pinned Fedora Cloud qcow2 image with `cloud-init`-compatible defaults.

#### Scenario: Operator provisions Fedora Cloud on qemu
- **WHEN** an operator runs the qemu provisioning workflow with the `fedora-cloud` OS profile and valid networking/SSH inputs
- **THEN** the system provisions a VM on local `libvirt` using the configured Fedora Cloud cloud image
- **AND** cloud-init configures hostname, fixed IP, and SSH access according to the shared provisioning contract

#### Scenario: Profile prerequisites are not met
- **WHEN** the `fedora-cloud` profile image metadata is missing, invalid, or incompatible with the qemu provisioning workflow
- **THEN** the provisioning workflow exits non-zero with a clear error describing the missing or invalid profile prerequisites
- **AND** no partially configured host is reported as ready

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

