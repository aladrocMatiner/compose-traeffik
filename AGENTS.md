<!-- OPENSPEC:START -->
# OpenSpec Instructions

These instructions are for AI assistants working in this project.

Always open `@/openspec/AGENTS.md` when the request:
- Mentions planning or proposals (words like proposal, spec, change, plan)
- Introduces new capabilities, breaking changes, architecture shifts, or big performance/security work
- Sounds ambiguous and you need the authoritative spec before coding

Use `@/openspec/AGENTS.md` to learn:
- How to create and apply change proposals
- Spec format and conventions
- Project structure and guidelines

Keep this managed block so 'openspec update' can refresh the instructions.

<!-- OPENSPEC:END -->

## Project-specific AI guidance

### Infra provisioning (upcoming work)

- When a request mentions VM provisioning, libvirt/QEMU, Proxmox, Terraform, cloud-init, static IPs, or host bootstrap, read `SKILL.md` before editing.
- Treat VM provisioning/target additions as architecture work: create or update an OpenSpec change before implementation unless it is a small bug fix.
- Current provisioning scope is split in phases:
  - Phase 1: `terraform` + `cloud-init` + shell scripts to provision Ubuntu hosts, set fixed IP + SSH, and install Docker/Compose plugin.
  - Phase 2: `ansible` for higher-level host configuration and stack deployment (`deployment-project` workflow).
- Keep a shared input/output contract across targets (`libvirt` local first-class, `proxmox` remote first-class) so later automation can consume the same host metadata.
- Prefer repository-local scripts as operational entrypoints (for example `scripts/infra-*.sh`) instead of long one-off command sequences in docs.
- Do not commit secrets or provider credentials; use environment variables and ignored tfvars/vault files.
- Pin provider versions and Ubuntu base image references during implementation to keep provisioning reproducible.

### Deployment projects and Ansible (active work)

- When a request mentions `deployment-project`, project catalog/manifests, `deployment/projects/*`, Traefik application stacks, StepCA/Keycloak integration, or Ansible roles/playbooks, read `SKILL.md` before editing.
- Treat changes to project manifests, dependency guardrails, TLS mode behavior, or project orchestration as spec-driven work: create/update the corresponding OpenSpec change first unless it is a small bug fix.
- Keep project ids and directory names aligned (for example `traefik-<service>`), and preserve deterministic host/TLS contracts defined in OpenSpec (`public_host`, `BASE_DOMAIN`, `tls_mode`, `depends_on_projects`).
- Keep deployment entrypoints in repository scripts/Make targets (`deployment/scripts/*`, `make deployment-*`) and avoid hidden manual steps in docs.
