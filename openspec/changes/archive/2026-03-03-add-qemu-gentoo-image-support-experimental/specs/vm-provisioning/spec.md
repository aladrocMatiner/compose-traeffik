## ADDED Requirements

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
