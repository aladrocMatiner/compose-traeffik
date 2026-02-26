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
  - Phase 2: `ansible` for higher-level host configuration and stack deployment (handled later).
- Keep a shared input/output contract across targets (`libvirt` local first-class, `proxmox` remote first-class) so later automation can consume the same host metadata.
- Prefer repository-local scripts as operational entrypoints (for example `scripts/infra-*.sh`) instead of long one-off command sequences in docs.
- Do not commit secrets or provider credentials; use environment variables and ignored tfvars/vault files.
- Pin provider versions and Ubuntu base image references during implementation to keep provisioning reproducible.
