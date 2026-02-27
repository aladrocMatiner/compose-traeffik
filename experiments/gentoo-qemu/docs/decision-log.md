# Decision Log (Gentoo QEMU Experimental)

### 2026-02-27 - Keep Gentoo support explicitly experimental

- Context: qemu/libvirt provisioning now exposes `os=gentoo` with `init=openrc|systemd`, but Docker parity is not implemented for Gentoo.
- Options considered:
  - Promote to full deployment-ready support.
  - Keep experimental with explicit gate metadata and warnings.
- Decision: Keep `gentoo` as experimental and gate runtime claims through per-variant manifest fields.
- Consequences:
  - `openrc` remains default baseline.
  - `systemd` remains opt-in override (`init=systemd`) without implying Docker parity.
- Evidence links:
  - `experiments/gentoo-qemu/manifests/gentoo-openrc-stage3-hostkernel-20260222T170100Z.yaml`
  - `experiments/gentoo-qemu/manifests/gentoo-systemd-stage3-hostkernel-20260222T170100Z.yaml`
  - `scripts/infra-provision.sh` (`validate_gentoo_manifest`)

### 2026-02-27 - Use host-kernel builder strategy for v1 qualification

- Context: project needs reproducible local qcow2 artifacts for Gentoo without introducing long custom kernel pipelines in this change.
- Options considered:
  - Build distro-native Gentoo kernel per image.
  - Reuse host kernel/initrd/modules as pragmatic bootstrap path.
- Decision: Use host-kernel copy strategy for both `openrc` and `systemd` builders in v1.
- Consequences:
  - Faster local iteration.
  - Image portability depends on builder host kernel artifacts.
- Evidence links:
  - `experiments/gentoo-qemu/scripts/build-openrc-cloud-image.sh`
  - `experiments/gentoo-qemu/scripts/build-systemd-cloud-image.sh`

### 2026-02-27 - Docker bootstrap parity deferred for Gentoo

- Context: existing host bootstrap scripts support Ubuntu/Debian only; Gentoo would require separate package/service/cgroup validation.
- Options considered:
  - Include Docker parity in this change.
  - Defer Docker parity to dedicated follow-up.
- Decision: Defer Docker parity and mark `qualified_docker_bootstrap=false` in both Gentoo manifests.
- Consequences:
  - `deployment-bootstrap`/`deployment-bootstrap-check` remain unsupported for `os=gentoo`.
  - Messaging stays explicit and avoids overpromising readiness.
- Evidence links:
  - `scripts/host-bootstrap.sh`
  - `scripts/host-bootstrap-check.sh`
  - `scripts/README.md`
