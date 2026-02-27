## 1. OpenSpec Contract Finalization

- [ ] 1.1 Review and approve the `vm-provisioning` and `host-bootstrap` deltas for Phase 1 scope (no Ansible deployment yet).
- [x] 1.2 Validate change artifacts with `openspec validate add-vm-bootstrap-targets --strict`.

## 2. Infrastructure Layout and Shared Contracts

- [x] 2.1 Create the repository structure for `infra/terraform/` and `infra/cloud-init/`.
- [x] 2.2 Define shared Terraform variables for VM identity, static networking, SSH access, and Ubuntu image source.
- [x] 2.3 Define a stable Terraform output schema (JSON-friendly) for hostname, IP, SSH user, and target metadata.

## 3. libvirt (local QEMU) Target

- [x] 3.1 Implement a Terraform root/module wiring for local `libvirt` provisioning using Ubuntu cloud images.
- [x] 3.2 Attach cloud-init data and verify hostname + static IP + SSH access on first boot.
- [x] 3.3 Document/encode target-specific requirements (network/pool/bridge defaults or required inputs).

## 4. Proxmox (remote) Target

- [x] 4.1 Select and pin a Terraform Proxmox provider compatible with the target environment.
- [x] 4.2 Implement Terraform wiring for remote Proxmox provisioning with cloud-init-enabled VM creation/cloning.
- [x] 4.3 Ensure Proxmox credentials and sensitive values are consumed via environment variables or ignored files only.
- [x] 4.4 Verify the Proxmox target emits the same core output schema as `libvirt`.

## 5. cloud-init Templates

- [x] 5.1 Implement shared `cloud-init` template(s) for SSH user, authorized keys, hostname, and minimal packages.
- [x] 5.2 Implement static network configuration templating for fixed IPs (with gateway/DNS inputs).
- [x] 5.3 Keep `cloud-init` scope limited to bootstrap prerequisites and exclude Docker stack deployment logic.

## 6. Host Bootstrap Scripts (Docker Ready)

- [x] 6.1 Implement a provisioning wrapper script (e.g., `scripts/infra-provision.sh`) to run Terraform by target consistently.
- [x] 6.2 Implement a host bootstrap script (e.g., `scripts/host-bootstrap.sh`) that installs Docker Engine and Docker Compose plugin on Ubuntu hosts over SSH.
- [x] 6.3 Implement a readiness verification script (e.g., `scripts/host-bootstrap-check.sh`) to confirm SSH and Docker/Compose availability.
- [x] 6.4 Make the bootstrap workflow safe to re-run or fail clearly when rerun is unsupported for a specific step.

## 7. Validation and Handoff Readiness

- [x] 7.1 Add basic validation commands/documentation for `terraform fmt`, `terraform validate`, and target smoke checks.
- [x] 7.2 Confirm the host metadata outputs can be consumed by future Ansible inventory generation without format changes.
- [x] 7.3 Document secrets handling and operator prerequisites for both targets (SSH keys, Proxmox API access, network assumptions).
