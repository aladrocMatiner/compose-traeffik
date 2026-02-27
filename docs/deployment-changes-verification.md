# Deployment Changes Verification (2026-02-27)

This note captures implementation and validation evidence used to close the active deployment OpenSpec changes on branch `deployments`.

## Scope Decisions

- `deployment-ssh` / `deployment-list` host-access selectors are accepted for `target=<qemu|proxmox>` and `name=<vm>`.
- Insecure debug credentials are **not** implemented. Security stance remains:
  - SSH key auth
  - explicit fallback guidance to hypervisor console (`virsh console <vm>`) when IP/SSH resolution fails
- `qemu` image-profile support is provisioning-first:
  - cloud-init + fixed IP + SSH contract
  - Docker bootstrap parity only for `ubuntu`, `debian12`, `debian13`
  - `opensuse-leap`, `almalinux9`, `rockylinux9`, `fedora-cloud`, and `gentoo` remain non-parity profiles for bootstrap scripts

## QEMU Profile Metadata and Integrity

Pinned defaults and checksum verification are implemented in `scripts/infra-provision.sh`:

- `debian12`: pinned Debian cloud image + SHA512 sums verification
- `debian13`: pinned Debian cloud image + SHA512 sums verification
- `opensuse-leap`: pinned openSUSE Leap image + SHA256 verification (`.sha256`)
- `almalinux9`: pinned AlmaLinux 9.7 image + SHA256 verification (`CHECKSUM`)
- `rockylinux9`: pinned Rocky 9.7 image + SHA256 verification (`CHECKSUM`)
- `fedora-cloud`: pinned Fedora 41-1.4 image + SHA256 verification (`CHECKSUM`)

These defaults and override variables are documented in:

- `.env.example` (Deployment VM Provisioning section)
- `scripts/README.md` (QEMU image profile defaults table)

## Debian 13 Qualification Notes

Debian 13 profile is implemented as `os=debian13` (with alias `os=debian`) in:

- `scripts/infra-provision.sh` selector and validation logic
- `Makefile` target UX/help text
- `scripts/README.md` examples/notes

Evidence of metadata strategy:

- official image URL pinning to dated artifact path
- checksum fetch from upstream `SHA512SUMS`
- local file integrity verification before plan/apply
- explicit validation error for unsupported `init=` with non-Gentoo OS

## Gentoo Experimental Gates

Per-variant manifests are in place:

- `experiments/gentoo-qemu/manifests/gentoo-openrc-stage3-hostkernel-20260222T170100Z.yaml`
- `experiments/gentoo-qemu/manifests/gentoo-systemd-stage3-hostkernel-20260222T170100Z.yaml`

`scripts/infra-provision.sh` enforces manifest prerequisites for `os=gentoo`:

- required manifest file exists
- `os=gentoo`
- matching `init_system`
- `cloud_init_support` present and not `none`
- `qualified_qemu_provisioning=true`

Workspace evidence and decisions are updated in:

- `experiments/gentoo-qemu/docs/qualification-matrix.md`
- `experiments/gentoo-qemu/docs/decision-log.md`

## Validation Commands

Executed in this branch:

```bash
openspec validate add-vm-bootstrap-targets --strict
openspec validate add-deployment-ssh-vm-selector --strict
openspec validate add-qemu-debian12-image-support --strict
openspec validate add-qemu-debian13-image-support --strict
openspec validate add-qemu-opensuse-leap-image-support --strict
openspec validate add-qemu-almalinux9-image-support --strict
openspec validate add-qemu-rockylinux9-image-support --strict
openspec validate add-qemu-fedora-cloud-image-support --strict
openspec validate add-qemu-gentoo-image-support-experimental --strict
tests/smoke/test_deployment_make_targets.sh
tests/smoke/test_deployment_access_cli.sh
tests/smoke/test_deployment_profile_metadata.sh
```
