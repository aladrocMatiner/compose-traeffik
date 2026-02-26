# AGENTS.md (Gentoo QEMU Experimental Workspace)

## Scope

This workspace is for Gentoo/qemu (`libvirt`) discovery, qualification, and evidence collection. Treat it as an isolated experimental module.

## Working Rules

- Prefer adding new Gentoo-specific scripts here instead of modifying top-level `scripts/` prematurely.
- Record every major decision in `docs/decision-log.md` with links to evidence in `artifacts/`.
- Pin image sources and checksums in `manifests/`; avoid unpinned `latest` references.
- Keep shell scripts reproducible (`bash`, `set -euo pipefail`).
- Store large/ephemeral files in `work/` and `artifacts/runs/` (gitignored).
- If a spike reveals a reusable change for the stable qemu path, document the minimal integration diff before touching the main flow.

## Integration Boundary

Do not wire this workspace into `make deployment-ready` or the stable Ubuntu path until the `qemu-provisionable` and `ansible-ready` gates are satisfied and documented.

## Future Extraction Goal

Assume this directory may become a separate repository or submodule. Keep internal docs/scripts self-contained and avoid hidden dependencies on parent-repo paths.
