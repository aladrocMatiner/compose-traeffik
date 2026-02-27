---
name: infra-vm-bootstrap
description: Plan and implement this repository's VM provisioning and host bootstrap workflow for Docker Compose deployments using Terraform, cloud-init, and shell scripts. Use when requests mention libvirt/QEMU, Proxmox, Ubuntu cloud images, fixed IPs, SSH bootstrap, Docker installation on hosts, or preparing a future Ansible handoff.
---

# Infra VM Bootstrap Skill

Implement the provisioning stack in two phases and keep the boundary strict.

## Follow the phase boundary

- Implement Phase 1 with `terraform` + `cloud-init` + shell scripts only.
- Use `cloud-init` for bootstrap prerequisites: hostname, user, SSH keys, fixed network config, and minimal packages.
- Keep Docker host setup in scripts (not large `cloud-init` payloads) so it stays easy to iterate.
- Do not add application `docker compose up` deployment logic to the host bootstrap scripts.
- Treat Ansible integration as a later phase; preserve machine-readable outputs to support it.

## Keep target implementations aligned

- Support both targets with the same conceptual inputs where possible:
  - VM identity (`name`, `hostname`)
  - Network (`ip`, `cidr`, `gateway`, `dns_servers`)
  - Access (`ssh_user`, `ssh_public_key`)
  - Image (`ubuntu_image`, optional checksum/source)
- Isolate target-specific fields and credentials:
  - `libvirt`: pool/network/volume specifics
  - `proxmox`: API endpoint, node, datastore/bridge, token auth
- Prefer a shared Terraform module for common VM/cloud-init rendering and per-target roots for provider wiring.

## Favor this repo layout (unless blocked by existing code)

- `infra/terraform/modules/vm-base/`
- `infra/terraform/targets/libvirt/`
- `infra/terraform/targets/proxmox/`
- `infra/cloud-init/user-data.yaml.tftpl`
- `infra/cloud-init/network-config.yaml.tftpl` (if separate template is needed)
- `deployment/scripts/infra-provision.sh`
- `deployment/scripts/host-bootstrap.sh`
- `deployment/scripts/host-bootstrap-check.sh`

## Implementation workflow

1. Update or create the OpenSpec change before coding behavior.
2. Scaffold Terraform target roots and shared module with pinned providers.
3. Render cloud-init templates from Terraform variables for Ubuntu + static IP + SSH.
4. Expose `terraform output -json` host metadata for downstream automation.
5. Implement host bootstrap script to install Docker Engine + Compose plugin on Ubuntu.
6. Implement verification script that checks SSH reachability and Docker readiness.
7. Test both targets incrementally (`libvirt` locally first, `proxmox` second).

## Guardrails

- Keep provider credentials and secrets out of Git-tracked files.
- Make scripts idempotent or safe to re-run where practical.
- Fail fast with clear messages when required variables or network fields are missing.
- Pin Ubuntu image versions and Terraform providers to reduce drift.
- Prefer `terraform validate`, `terraform fmt -check`, and smoke checks over manual inspection only.

## Future Ansible handoff (do not implement yet unless requested)

- Keep outputs/inventory data easy to consume (`json` or simple inventory template).
- Avoid embedding long-lived configuration management logic in shell scripts.
- Limit scripts to "host ready for configuration management" concerns.
