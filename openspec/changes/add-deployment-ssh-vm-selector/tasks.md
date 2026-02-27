## 1. OpenSpec Contract

- [ ] 1.1 Review and approve `host-access` requirements for `deployment-ssh` selection by `target=<qemu|proxmox>` and `name=<name>`.
- [ ] 1.2 Confirm the security stance for fallback access (console-only vs optional insecure debug credentials).
- [x] 1.3 Validate change artifacts with `openspec validate add-deployment-ssh-vm-selector --strict`.

## 2. SSH Access Selector (routing + qemu/libvirt)

- [x] 2.1 Update `deployment-ssh` to accept selector UX `make deployment-ssh target=<qemu|proxmox> name=<name>`.
- [x] 2.2 Preserve current Terraform-output-based resolution when no selector is provided.
- [x] 2.3 Normalize `target=qemu` to the local `libvirt` backend and emit clear errors for unsupported targets.
- [x] 2.4 Implement libvirt domain existence checks and clear operator errors for unknown VM names when `target=qemu`.

## 3. deployment-list (inventory by target)

- [x] 3.1 Add `deployment-list` UX with `target=<qemu|proxmox>` routing.
- [x] 3.2 Implement `target=qemu` listing using `virsh` and a deterministic managed-resource filter (e.g., configurable name prefix).
- [x] 3.3 Include operator-useful fields in list output (at least name and state; optionally IP if resolvable) and make "domain vs image" distinctions clear if disk artifacts are included.
- [x] 3.4 Define `target=proxmox` behavior for this phase (implemented listing or explicit "not yet supported" error path).

## 4. IP/User Resolution and Fallbacks (deployment-ssh)

- [x] 4.1 Implement IP resolution for `target=qemu` VMs using `virsh domifaddr` (agent first, then ARP).
- [x] 4.2 Add DHCP lease fallback using VM MAC + `virsh net-dhcp-leases` when applicable.
- [x] 4.3 Emit clear diagnostics describing which resolution path succeeded or failed.
- [x] 4.4 Add fallback instructions (`virsh console <vm>`) when SSH is unavailable or IP cannot be resolved for `target=qemu`.
- [x] 4.5 Define `target=proxmox` behavior for this phase (implemented resolver or explicit "not yet supported" error path).

## 5. Optional Debug Credentials (Only If Approved)

- [ ] 5.1 Decide whether to implement a local-only insecure debug login mode in this change.
- [ ] 5.2 If approved, gate the feature behind explicit flags/vars and avoid hardcoded default passwords in Git-tracked files.
- [ ] 5.3 Document warnings and operator workflow for the debug mode.

## 6. Documentation and Validation

- [x] 6.1 Update `make help` and `scripts/README.md` with `deployment-ssh`/`deployment-list` examples and fallback behavior.
- [x] 6.2 Add/adjust smoke checks or script-level validation for selector parsing, listing output, and error messages.
- [ ] 6.3 Test `deployment-list target=qemu` with multiple VMs and verify filter behavior (managed vs unmanaged).
- [ ] 6.4 Test `deployment-ssh` against at least one VM in Terraform state and one VM selected by `target=qemu name=<virsh-name>`.
