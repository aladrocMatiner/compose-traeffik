# host-access Specification

## Purpose
TBD - created by archiving change add-deployment-ssh-vm-selector. Update Purpose after archive.
## Requirements
### Requirement: deployment-ssh supports explicit host selection by backend target and name
The system SHALL allow operators to select a deployment host for `deployment-ssh` by providing an explicit backend target and host name (for example `make deployment-ssh target=<qemu|proxmox> name=<host-name>`).

#### Scenario: Operator selects a qemu/libvirt VM explicitly
- **WHEN** an operator runs `make deployment-ssh target=qemu name=<virsh-name>`
- **THEN** the system resolves the selected local `libvirt` domain by name
- **AND** it attempts SSH access to that VM instead of relying only on the current Terraform state

#### Scenario: Operator selects a proxmox host explicitly
- **WHEN** an operator runs `make deployment-ssh target=proxmox name=<host-name>`
- **THEN** the system routes resolution through the `proxmox` access path
- **AND** it either resolves SSH access for that host or returns a clear unsupported-target message if Proxmox access is not implemented in the current phase

### Requirement: deployment-list supports explicit backend inventory by target
The system SHALL provide a `deployment-list` command that lists deployment resources by explicit backend target (for example `make deployment-list target=<qemu|proxmox>`).

#### Scenario: Operator lists qemu/libvirt deployments
- **WHEN** an operator runs `make deployment-list target=qemu`
- **THEN** the system enumerates local `libvirt` resources using a deterministic managed-resource filter
- **AND** it returns operator-useful information for each matching deployment (at least host/domain name and state)

#### Scenario: Operator lists proxmox deployments
- **WHEN** an operator runs `make deployment-list target=proxmox`
- **THEN** the system routes listing through the Proxmox inventory path
- **AND** it either returns the list or emits a clear unsupported-target message if Proxmox inventory is not implemented in the current phase

#### Scenario: No managed deployments found
- **WHEN** an operator runs `deployment-list` for a supported target and no managed resources match the filter
- **THEN** the command exits successfully
- **AND** it reports an empty result with a clear message rather than failing ambiguously

### Requirement: deployment-ssh preserves Terraform-state mode when no VM selector is provided
The system SHALL preserve the existing `deployment-ssh` behavior that resolves host connection data from Terraform outputs when no explicit VM selector is provided.

#### Scenario: Operator uses deployment-ssh without selector
- **WHEN** an operator runs `make deployment-ssh` without a libvirt VM selector
- **THEN** the system resolves host access using Terraform outputs from the active deployment state
- **AND** the command behavior remains backward compatible with the current workflow

### Requirement: qemu/libvirt-selected host access uses deterministic resolution with operator-visible diagnostics
For `target=qemu`, the system SHALL resolve host connection data using a deterministic fallback strategy (including `virsh` address sources and, when needed, DHCP lease lookup), and SHALL emit clear diagnostics when resolution fails.

#### Scenario: Address resolution succeeds without guest agent
- **WHEN** a selected VM is reachable on the network but `qemu-guest-agent` is unavailable
- **THEN** the system can fall back to an alternate resolution source (such as ARP or libvirt DHCP leases)
- **AND** it informs the operator which resolution source was used

#### Scenario: Address resolution fails
- **WHEN** no IP address can be resolved for the selected `target=qemu` VM
- **THEN** the system exits non-zero with a clear error
- **AND** it provides recovery guidance such as `virsh console <virsh-name>`

### Requirement: qemu/libvirt inventory distinguishes managed deployments from unrelated resources
For `target=qemu`, the system SHALL apply a deterministic criterion (such as a documented naming prefix) to identify resources considered "created by this tooling", and SHALL document or display that criterion to the operator.

#### Scenario: Hypervisor contains mixed resources
- **WHEN** the local `libvirt` instance contains both project-managed VMs and unrelated VMs
- **THEN** `deployment-list target=qemu` filters or marks resources using the documented managed-resource criterion
- **AND** the operator can understand why a VM is included or excluded

### Requirement: Insecure fallback credentials are not enabled by default
The system SHALL NOT provision or assume a default static fallback credential (for example `root` with a hardcoded password) for deployment host access. Any insecure debug-login mode, if supported, SHALL require explicit operator opt-in and clear warnings.

#### Scenario: Operator uses default access workflow
- **WHEN** an operator uses `deployment-ssh` or related access helpers without enabling an explicit debug-login mode
- **THEN** the system does not expose or rely on hardcoded fallback credentials
- **AND** the access workflow uses SSH keys and/or local console recovery only

#### Scenario: Operator enables debug-login mode explicitly
- **WHEN** an operator explicitly enables a local-only debug credential mode (if implemented)
- **THEN** the system emits warnings describing the security risk
- **AND** the mode is treated as opt-in behavior rather than a default access path

