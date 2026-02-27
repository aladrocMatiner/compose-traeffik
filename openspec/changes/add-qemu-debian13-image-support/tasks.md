## 1. OpenSpec Contract and Scope

- [x] 1.1 Confirm that this change is scoped to `qemu/libvirt` `vm-provisioning` only (no Docker/bootstrap parity).
- [x] 1.2 Confirm desired operator-facing OS selector name (`debian13`) for qemu.
- [x] 1.3 Validate this change with `openspec validate add-qemu-debian13-image-support --strict`.

## 2. Stage A - Image Selection and Provenance (`image-selected`)

- [x] 2.1 Identify the official Debian 13 cloud image candidate for `amd64` and `qcow2`.
- [x] 2.2 Record pinned URL/version (or dated artifact path) for reproducible downloads.
- [x] 2.3 Record checksum source and verification procedure (SHA256 or equivalent).
- [x] 2.4 Define fallback candidate/image source in case of upstream URL or format changes.
- [x] 2.5 Decide where image metadata lives (inline in script vs manifest file) and document the rationale.
- [x] 2.6 Capture image metadata evidence (URL/version/checksum/date/source) for review.

## 3. Stage B - cloud-init Compatibility (`cloud-init-compatible`)

- [x] 3.1 Boot the Debian 13 image on local `qemu/libvirt` with NoCloud `cloud-init` seed.
- [x] 3.2 Validate `cloud-init status --wait` completes without critical failures.
- [x] 3.3 Validate hostname is applied correctly.
- [x] 3.4 Validate SSH key injection for the current operator public key.
- [x] 3.5 Confirm SSH login works (pre-static-IP validation acceptable if needed).
- [x] 3.6 Capture any Debian 13-specific differences in SSH service naming or package behavior.
- [x] 3.7 Decide whether current shared `user-data` template works unchanged or requires minimal branching.

## 4. Stage C - Static Networking and Reboot Persistence (`qemu-provisionable`)

- [x] 4.1 Validate `cloud-init` network-config v2 applies a fixed IP on `libvirt default` NAT.
- [x] 4.2 Validate gateway and DNS resolution work after first boot.
- [x] 4.3 Validate SSH reachability over the configured fixed IP.
- [x] 4.4 Reboot the VM and validate fixed IP + hostname + SSH persist.
- [x] 4.5 Capture interface naming and renderer behavior (`ens3`, networkd/ifupdown/etc.) as evidence.
- [x] 4.6 Run at least one negative test (invalid checksum or invalid image metadata) and capture failure behavior.
- [x] 4.7 Decide whether a Debian 13-specific networking template adjustment is needed.

## 5. Stage D - Main Flow Integration Prep (`integration-ready` for vm-provisioning)

- [x] 5.1 Define required changes in `deployment/scripts/infra-provision.sh` for `os=debian13` image metadata and validation.
- [x] 5.2 Define whether `Makefile` help/examples need `debian13` examples and exact UX wording.
- [x] 5.3 Define error messages for unsupported parameters (e.g. `init=` with `os=debian13`).
- [x] 5.4 Define any minimal `cloud-init` template branching required (if any) and justify it.
- [x] 5.5 Confirm no changes are needed in Terraform `libvirt` resources beyond image path/metadata handling (or document exact changes).

## 6. Stage E - Docker Bootstrap Follow-up Boundary (Out of Scope Here)

- [x] 6.1 Document Debian 13 Docker bootstrap follow-up questions (repo URL/codename/packages/service checks).
- [x] 6.2 Decide whether Debian 13 Docker parity will be a separate OpenSpec change or folded into a broader Debian bootstrap change.
- [x] 6.3 Document the non-goal clearly in proposal/design so reviewers do not assume `deployment-ready` parity.

## 7. Documentation and Evidence

- [x] 7.1 Record test evidence for image selection, `cloud-init`, fixed IP, and SSH.
- [x] 7.2 Document known limitations/caveats found during qualification.
- [x] 7.3 Update operational docs / `make help` examples only when implementation lands (follow-up task placeholder).

## 8. Review Readiness

- [x] 8.1 Review proposal/design for clear gates, negative tests, and handoff boundaries.
- [x] 8.2 Review spec delta wording to ensure it does not imply Docker/bootstrap support.
- [x] 8.3 Re-run `openspec validate add-qemu-debian13-image-support --strict` after edits.
