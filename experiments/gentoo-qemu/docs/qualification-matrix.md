# Qualification Matrix (Gentoo QEMU Experimental)

Baseline policy: `OpenRC` is the default/primary qualified baseline for Gentoo/qemu. `systemd` candidates may be tracked for explicit `init=systemd` experimental runs, but remain non-baseline unless explicitly promoted in a future change.

## Candidate Images

| Candidate | Source | Format | Arch | Init System | cloud-init | SSH | Python3 | Checksum | Status | Notes |
|---|---|---|---|---|---|---|---|---|---|---|
| `gentoo-openrc-stage3-hostkernel-20260222T170100Z` | Gentoo stage3 OpenRC tarball | qcow2 (project-built) | amd64 | OpenRC | image-built | yes | yes | SHA256 manifest + upstream checksum | qemu-provisionable | Default baseline; manifest gate enabled in `infra-provision`. |
| `gentoo-systemd-stage3-hostkernel-20260222T170100Z` | Gentoo stage3 systemd tarball | qcow2 (project-built) | amd64 | systemd | image-built | yes | yes | SHA256 manifest + upstream checksum | qemu-provisionable (experimental) | Explicit override path (`init=systemd`), non-default baseline. |

## Gate Status

| Gate | Status | Date | Evidence | Notes |
|---|---|---|---|---|
| discovery-complete | pass | 2026-02-27 | `manifests/*.yaml` sources + checksums | OpenRC + systemd candidates selected with pinned metadata. |
| image-qualified | pass | 2026-02-27 | builder scripts + manifest cloud-init fields | Both variants include cloud-init/SSH/python package path in builder contract. |
| qemu-provisionable | pass (experimental) | 2026-02-27 | `deployment/scripts/infra-provision.sh` manifest gate + cloud-init templates | Provisioning is allowed only when manifest marks `qualified_qemu_provisioning=true`. |
| ansible-ready | partial | 2026-02-27 | manifest flags (`qualified_ansible_ready`) | OpenRC marked ready, systemd remains not-ready for ansible gate. |
| docker-feasibility-assessed | deferred | 2026-02-27 | decision log + manifest flags | Docker parity intentionally out of scope in this change. |

## Evidence Pointers

- Provisioning integration: `deployment/scripts/infra-provision.sh`
- Gentoo builders:
  - `experiments/gentoo-qemu/scripts/build-openrc-cloud-image.sh`
  - `experiments/gentoo-qemu/scripts/build-systemd-cloud-image.sh`
- Manifest gates:
  - `experiments/gentoo-qemu/manifests/gentoo-openrc-stage3-hostkernel-20260222T170100Z.yaml`
  - `experiments/gentoo-qemu/manifests/gentoo-systemd-stage3-hostkernel-20260222T170100Z.yaml`
