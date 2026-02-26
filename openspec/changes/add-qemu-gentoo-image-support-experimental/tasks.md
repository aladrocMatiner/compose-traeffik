## 1. Planning and Governance (This Proposal)

- [ ] 1.1 Confirm that `Gentoo` remains scoped as `Experimental` until all qualification gates are met.
- [ ] 1.2 Confirm acceptance criteria for this proposal (plan quality + isolated workspace + spec delta clarity).
- [ ] 1.3 Approve the maturity-gate model (`discovery-complete` -> `image-qualified` -> `qemu-provisionable` -> `ansible-ready` -> `docker-feasibility-assessed`).
- [x] 1.4 Confirm `OpenRC` as the default/primary qualification target and baseline; allow `systemd` only via explicit `init=systemd` override (experimental) when supported by a qualified manifest.

## 2. Isolated Workspace Scaffolding (`experiments/gentoo-qemu/`)

- [x] 2.1 Create isolated directory structure for Gentoo qemu experimentation (docs, manifests, scripts, artifacts, work, cloud-init).
- [x] 2.2 Add local `.gitignore` to exclude qcow2/images, caches, logs, and runtime artifacts.
- [x] 2.3 Add `README.md` describing scope, boundaries, and future repo/submodule extraction intent.
- [x] 2.4 Add local `AGENTS.md` with workflow rules and integration boundaries.
- [x] 2.5 Add documentation templates for qualification matrix and decision log.
- [x] 2.6 Add placeholder script/manifest readmes to guide future implementation.

## 3. Stage A - Discovery and Candidate Image Qualification

- [ ] 3.1 Identify candidate Gentoo image sources (official and fallback/community/project-prepared).
- [ ] 3.2 Record image format, architecture, and boot assumptions for each candidate.
- [ ] 3.3 Verify whether each candidate includes `cloud-init` and what datasource it expects.
- [ ] 3.4 Verify whether each candidate includes `openssh` and `python3`.
- [ ] 3.5 Determine init system (`OpenRC` or `systemd`) for each candidate and mark whether it is eligible for the `OpenRC` baseline.
- [ ] 3.6 Define pinned image metadata format (URL, version/date, checksum, checksum source, variant, init system).
- [ ] 3.7 Document checksum/signature verification procedure.
- [ ] 3.8 Select an `OpenRC` primary candidate and at least one fallback candidate (preferably `OpenRC`; `systemd` fallback allowed as explicit `init=systemd` experimental override candidate).
- [ ] 3.9 Record discovery outcomes and risks in `docs/qualification-matrix.md`.

## 4. Stage B - Boot and cloud-init Baseline (`image-qualified`)

- [ ] 4.1 Create a minimal boot smoke-test script in the isolated workspace (non-integrated spike).
- [ ] 4.2 Boot the selected image in local qemu/libvirt with NoCloud seed (`cloud-init`).
- [ ] 4.3 Validate `cloud-init` runs and capture logs/status.
- [ ] 4.4 Validate hostname configuration via `cloud-init`.
- [ ] 4.5 Validate SSH key injection works with the current operator public key.
- [ ] 4.6 Capture init system evidence and `OpenRC` service-management commands used by the baseline candidate.
- [ ] 4.7 Document any cloud-init module gaps or required Gentoo-specific template adjustments.
- [ ] 4.8 Decide whether the `OpenRC` baseline candidate meets `image-qualified` gate or fallback is required.

## 5. Stage C - Static Networking on libvirt (`qemu-provisionable`)

- [ ] 5.1 Validate `cloud-init` static IP configuration on libvirt NAT (`default`) network.
- [ ] 5.2 Capture interface name and renderer behavior (networkd/NetworkManager/netifrc/etc.).
- [ ] 5.3 Validate gateway and DNS resolution after first boot.
- [ ] 5.4 Validate SSH reachability over the static IP.
- [ ] 5.5 Reboot the VM and validate network + SSH persistence.
- [ ] 5.6 Run negative test with invalid/incomplete manifest to confirm clear failure behavior.
- [ ] 5.7 Document any need for Gentoo-specific `network-config` template or fallback strategy.
- [ ] 5.8 Decide if `qemu-provisionable` gate is met for the selected baseline variant.

## 6. Stage D - Ansible-Ready Baseline (`ansible-ready`)

- [ ] 6.1 Validate `python3` availability (preinstalled or reproducible installation step).
- [ ] 6.2 Validate SSH user/sudo behavior needed for Ansible handoff.
- [ ] 6.3 Document service-check command parity with `OpenRC` (`rc-service`, `rc-update`) and any comparison notes against `systemctl`.
- [ ] 6.4 Define a Gentoo-specific readiness check command set (without Docker).
- [ ] 6.5 Capture evidence for `ansible-ready` gate and unresolved caveats.

## 7. Stage E - Docker/Compose Feasibility Assessment (Decision Input)

- [ ] 7.1 Evaluate package-install path for Docker on the qualified Gentoo baseline (`emerge`, binpkgs, overlays if needed).
- [ ] 7.2 Evaluate service management/startup path for Docker under the baseline init system.
- [ ] 7.3 Assess kernel/cgroup requirements and whether the image/VM defaults satisfy Docker prerequisites.
- [ ] 7.4 Estimate bootstrap time/cost and reproducibility risk.
- [ ] 7.5 Document recommendation: `support`, `support-with-constraints`, or `defer`.
- [ ] 7.6 If not supporting now, draft follow-up OpenSpec change for Docker parity.

## 8. Integration Design Back Into Main `qemu` Flow (Follow-up Implementation Prep)

- [ ] 8.1 Define the provisioning interface contract for `make deployment os=<ubuntu|debian|gentoo>` and Gentoo-only `init=<openrc|systemd>` with default `openrc`.
- [ ] 8.2 Define validation behavior for missing/invalid Gentoo manifests in `scripts/infra-provision.sh`.
- [ ] 8.3 Define how image metadata will be stored and versioned in the main repo vs isolated workspace.
- [ ] 8.4 Define cloud-init template branching strategy (shared template vs Gentoo-specific override).
- [ ] 8.5 Define guardrails so `deployment-bootstrap` remains disabled or experimental until Docker parity is approved.
- [ ] 8.6 Define operator-facing error messages for invalid `init` values, use of `init` with non-Gentoo OS, unsupported Gentoo variants, or unqualified manifests.

## 9. Evidence and Documentation

- [ ] 9.1 Create `docs/decision-log.md` entries for each major decision (image source, baseline variant, template adjustments).
- [ ] 9.2 Create/maintain `docs/qualification-matrix.md` with pass/fail criteria and evidence links.
- [ ] 9.3 Capture per-run artifacts under `artifacts/runs/<timestamp>/` (logs, outputs, notes).
- [ ] 9.4 Record at least one failed candidate or negative test (if encountered) to preserve learning.
- [ ] 9.5 Document extraction-readiness status for the isolated workspace.

## 10. OpenSpec Validation and Review

- [x] 10.1 Validate this change with `openspec validate add-qemu-gentoo-image-support-experimental --strict` after updates.
- [x] 10.2 Review the spec delta wording to ensure it does not imply Docker parity.
- [x] 10.3 Review proposal/design for explicit gates, risks, and handoff conditions.
