## 1. Planning and Governance (This Proposal)

- [x] 1.1 Confirm that `Gentoo` remains scoped as `Experimental` until all qualification gates are met.
- [x] 1.2 Confirm acceptance criteria for this proposal (plan quality + isolated workspace + spec delta clarity).
- [x] 1.3 Approve the maturity-gate model (`discovery-complete` -> `image-qualified` -> `qemu-provisionable` -> `ansible-ready` -> `docker-feasibility-assessed`).
- [x] 1.4 Confirm `OpenRC` as the default/primary qualification target and baseline; allow `systemd` as an explicit non-default variant via `init=systemd` (experimental) when supported by a qualified manifest.
- [x] 1.5 Confirm target support level for the `systemd` variant in this proposal (`qemu-provisionable` minimum, `ansible-ready` optional) and document it as a gate expectation.

## 2. Isolated Workspace Scaffolding (`experiments/gentoo-qemu/`)

- [x] 2.1 Create isolated directory structure for Gentoo qemu experimentation (docs, manifests, scripts, artifacts, work, cloud-init).
- [x] 2.2 Add local `.gitignore` to exclude qcow2/images, caches, logs, and runtime artifacts.
- [x] 2.3 Add `README.md` describing scope, boundaries, and future repo/submodule extraction intent.
- [x] 2.4 Add local `AGENTS.md` with workflow rules and integration boundaries.
- [x] 2.5 Add documentation templates for qualification matrix and decision log.
- [x] 2.6 Add placeholder script/manifest readmes to guide future implementation.

## 3. Stage A - Discovery and Candidate Image Qualification

- [x] 3.1 Identify candidate Gentoo image sources (official and fallback/community/project-prepared).
- [x] 3.2 Record image format, architecture, and boot assumptions for each candidate.
- [x] 3.3 Verify whether each candidate includes `cloud-init` and what datasource it expects.
- [x] 3.4 Verify whether each candidate includes `openssh` and `python3`.
- [x] 3.5 Determine init system (`OpenRC` or `systemd`) for each candidate and mark whether it is eligible for the `OpenRC` baseline.
- [x] 3.6 Define pinned image metadata format (URL, version/date, checksum, checksum source, variant, init system).
- [x] 3.7 Document checksum/signature verification procedure.
- [x] 3.8 Select an `OpenRC` primary candidate and a `systemd` candidate (or document why `systemd` remains pending) with manifests mapped to `init=openrc|systemd`.
- [x] 3.9 Record discovery outcomes and risks in `docs/qualification-matrix.md`.

## 4. Stage B - Boot and cloud-init Baseline (`image-qualified`)

- [x] 4.1 Create a minimal boot smoke-test script in the isolated workspace (non-integrated spike).
- [x] 4.2 Boot the selected image in local qemu/libvirt with NoCloud seed (`cloud-init`).
- [x] 4.3 Validate `cloud-init` runs and capture logs/status.
- [x] 4.4 Validate hostname configuration via `cloud-init`.
- [x] 4.5 Validate SSH key injection works with the current operator public key.
- [x] 4.6 Capture init system evidence and `OpenRC` service-management commands used by the baseline candidate.
- [x] 4.7 Document any cloud-init module gaps or required Gentoo-specific template adjustments.
- [x] 4.8 Decide whether the `OpenRC` baseline candidate meets `image-qualified` gate or fallback is required.
- [x] 4.9 If a `systemd` candidate is in scope, run the same boot + cloud-init hostname/SSH checks and record evidence separately.
- [x] 4.10 Record whether the `systemd` candidate reaches `image-qualified` or remains discovery-only.

## 5. Stage C - Static Networking on libvirt (`qemu-provisionable`)

- [x] 5.1 Validate `cloud-init` static IP configuration on libvirt NAT (`default`) network.
- [x] 5.2 Capture interface name and renderer behavior (networkd/NetworkManager/netifrc/etc.).
- [x] 5.3 Validate gateway and DNS resolution after first boot.
- [x] 5.4 Validate SSH reachability over the static IP.
- [x] 5.5 Reboot the VM and validate network + SSH persistence.
- [x] 5.6 Run negative test with invalid/incomplete manifest to confirm clear failure behavior.
- [x] 5.7 Document any need for Gentoo-specific `network-config` template or fallback strategy.
- [x] 5.8 Decide if `qemu-provisionable` gate is met for the selected baseline variant.
- [x] 5.9 If `systemd` variant is in scope, validate fixed IP + SSH on libvirt and record a separate pass/fail decision for `qemu-provisionable`.
- [x] 5.10 Document any variant-specific networking differences (`OpenRC` vs `systemd`) and required template branching.

## 6. Stage D - Ansible-Ready Baseline (`ansible-ready`)

- [x] 6.1 Validate `python3` availability (preinstalled or reproducible installation step).
- [x] 6.2 Validate SSH user/sudo behavior needed for Ansible handoff.
- [x] 6.3 Document service-check command parity with `OpenRC` (`rc-service`, `rc-update`) and any comparison notes against `systemctl`.
- [x] 6.4 Define a Gentoo-specific readiness check command set (without Docker).
- [x] 6.5 Capture evidence for `ansible-ready` gate and unresolved caveats.
- [x] 6.6 Decide whether `systemd` is targeted for `ansible-ready` in this proposal iteration.
- [x] 6.7 If yes, validate `python3`, SSH/sudo, and readiness checks for `init=systemd` and record evidence separately.

## 7. Stage E - Docker/Compose Feasibility Assessment (Decision Input)

- [x] 7.1 Evaluate package-install path for Docker on the qualified Gentoo baseline (`emerge`, binpkgs, overlays if needed).
- [x] 7.2 Evaluate service management/startup path for Docker under the baseline init system.
- [x] 7.3 Assess kernel/cgroup requirements and whether the image/VM defaults satisfy Docker prerequisites.
- [x] 7.4 Estimate bootstrap time/cost and reproducibility risk.
- [x] 7.5 Document recommendation: `support`, `support-with-constraints`, or `defer`.
- [x] 7.6 If not supporting now, draft follow-up OpenSpec change for Docker parity.

## 8. Integration Design Back Into Main `qemu` Flow (Follow-up Implementation Prep)

- [x] 8.1 Define the provisioning interface contract for `make deployment os=<ubuntu|debian|gentoo>` and Gentoo-only `init=<openrc|systemd>` with default `openrc`.
- [x] 8.2 Define validation behavior for missing/invalid Gentoo manifests in `deployment/scripts/infra-provision.sh`.
- [x] 8.3 Define how image metadata will be stored and versioned in the main repo vs isolated workspace.
- [x] 8.4 Define cloud-init template branching strategy (shared template vs Gentoo-specific override).
- [x] 8.5 Define guardrails so `deployment-bootstrap` remains disabled or experimental until Docker parity is approved.
- [x] 8.6 Define operator-facing error messages for invalid `init` values, use of `init` with non-Gentoo OS, unsupported Gentoo variants, or unqualified manifests.
- [x] 8.7 Define how operator-facing messages expose per-variant support level (`OpenRC` vs `systemd`) without implying parity.
- [x] 8.8 Define readiness metadata fields (or manifest flags) needed to represent gate status per init variant.

## 9. Evidence and Documentation

- [x] 9.1 Create `docs/decision-log.md` entries for each major decision (image source, baseline variant, template adjustments).
- [x] 9.2 Create/maintain `docs/qualification-matrix.md` with pass/fail criteria and evidence links.
- [x] 9.3 Capture per-run artifacts under `artifacts/runs/<timestamp>/` (logs, outputs, notes).
- [x] 9.4 Record at least one failed candidate or negative test (if encountered) to preserve learning.
- [x] 9.5 Document extraction-readiness status for the isolated workspace.
- [x] 9.6 Maintain an init-variant evidence matrix (`OpenRC` / `systemd`) with gate status per variant.

## 10. OpenSpec Validation and Review

- [x] 10.1 Validate this change with `openspec validate add-qemu-gentoo-image-support-experimental --strict` after updates.
- [x] 10.2 Review the spec delta wording to ensure it does not imply Docker parity.
- [x] 10.3 Review proposal/design for explicit gates, risks, and handoff conditions.
