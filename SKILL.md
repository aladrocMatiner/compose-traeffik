---
name: infra-vm-bootstrap
description: Plan and implement this repository's deployment platform workflow across provisioning (Terraform/cloud-init), host bootstrap, and project orchestration (Ansible + deployment-project catalog). Use when requests mention libvirt/QEMU, Proxmox, Ubuntu cloud images, fixed IPs, SSH bootstrap, Docker installation, deployment-project manifests, Traefik app stacks, or StepCA/Keycloak integration.
---

# Infra and Project Deployment Skill

Implement provisioning and project deployment with clear boundaries.

## Keep the two lanes aligned

- Lane A (foundation): `terraform` + `cloud-init` + shell scripts for VM provisioning and host readiness.
- Lane B (projects): `ansible` + project manifests + `make deployment-project` for stack deployment.
- Use `cloud-init` for bootstrap prerequisites: hostname, user, SSH keys, fixed network config, and minimal packages.
- Keep Docker host setup in scripts (not large `cloud-init` payloads) so it stays easy to iterate.
- Do not mix application compose deployment logic into low-level bootstrap scripts.
- Keep machine-readable outputs from provisioning so Ansible/project orchestration can consume host metadata consistently.

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
- `deployment/ansible/roles/*`
- `deployment/ansible/playbooks/system_bootstrap.yml`
- `deployment/projects/<project-id>/`

## Implementation workflow

1. Update or create the OpenSpec change before coding behavior.
2. Scaffold Terraform target roots and shared module with pinned providers.
3. Render cloud-init templates from Terraform variables for Ubuntu + static IP + SSH.
4. Expose `terraform output -json` host metadata for downstream automation.
5. Implement host bootstrap script to install Docker Engine + Compose plugin on Ubuntu.
6. Implement verification script that checks SSH reachability and Docker readiness.
7. Implement/extend deployment project orchestration (`deployment-project`, catalog, manifest validation, dependency guardrails).
8. Test both targets incrementally (`libvirt` locally first, `proxmox` second), then validate project wiring.

## Project system contract guardrails

- Treat `make deployment-project` and `make deployment-project-list` as primary operator entrypoints.
- Keep project manifests explicit and validated (`id`, `description`, `repo_url`, `repo_ref`, `compose_profile`, `services`, `deploy_playbook`, `required_env`, `tls_mode`, optional `public_host`, optional `depends_on_projects`).
- For web projects, enforce Traefik as edge and TLS termination via selected `tls_mode`.
- Resolve hostname deterministically: default `<project-id>.<BASE_DOMAIN>`, optional override via `public_host`.
- Enforce dependency preflight (`depends_on_projects`) before compose apply when required by project contract.
- Preserve idempotency and block ad-hoc runtime service overrides that violate manifest-declared services.

## Guardrails

- Keep provider credentials and secrets out of Git-tracked files.
- Make scripts idempotent or safe to re-run where practical.
- Fail fast with clear messages when required variables or network fields are missing.
- Pin Ubuntu image versions and Terraform providers to reduce drift.
- Prefer `terraform validate`, `terraform fmt -check`, and smoke checks over manual inspection only.
- Keep outputs/inventory data easy to consume (`json` or simple inventory template) for Ansible handoff stages.
