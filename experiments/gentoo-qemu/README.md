# Gentoo on QEMU (Experimental Workspace)

This directory isolates the Gentoo/qemu qualification work from the stable provisioning flow.

## Purpose

- Qualify a Gentoo image/profile for local `qemu` (`libvirt`) provisioning.
- Ensure the default/primary qualified Gentoo baseline uses `OpenRC` for this project (`systemd` may be tracked as an explicit experimental override variant).
- Validate the minimum shared contract: `cloud-init` + fixed IP + SSH.
- Document evidence, risks, and decisions before integrating anything into the main `Makefile`/scripts.
- Keep the work ready for future extraction to a standalone repo or git submodule.

## Status Model (Maturity Gates)

- `discovery-complete`
- `image-qualified`
- `qemu-provisionable`
- `ansible-ready`
- `docker-feasibility-assessed`

Gentoo remains **Experimental** until the relevant gate is explicitly documented as passed.

## Boundaries

- Top-level integration is limited to explicit experimental hooks (`os=gentoo`, `init=<openrc|systemd>`) with manifest gate checks; production-readiness claims remain gated by this workspace evidence.
- Do not treat `systemd` Gentoo images as baseline-ready by default; they are explicit `init=systemd` experimental variants unless a future change promotes them.
- Do not claim Docker/Compose parity here without a dedicated feasibility decision.
- Keep artifacts/logs under `artifacts/` and local runtime files under `work/` (ignored by git).

## Layout

- `docs/`: decision log, qualification matrix, and feasibility notes
- `manifests/`: pinned image metadata (URL, checksum, variant, init system)
- `scripts/`: qualification scripts/spikes
- `cloud-init/`: Gentoo-specific cloud-init templates or overrides if needed
- `artifacts/`: captured run outputs/evidence
- `work/`: local scratch area (downloaded images, temporary files)

## Future Extraction

This directory is intentionally organized as a future submodule/repo candidate. Keep references to the parent repo minimal and explicit.
