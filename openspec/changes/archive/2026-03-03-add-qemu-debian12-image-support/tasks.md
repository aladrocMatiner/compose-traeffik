## 1. OpenSpec Contract

- [x] 1.1 Review and approve qemu image-profile scope for `Debian 12` (`vm-provisioning` only vs full bootstrap parity).
- [x] 1.2 Validate change artifacts with `openspec validate add-qemu-debian12-image-support --strict`.

## 2. QEMU Image Profile Definition

- [x] 2.1 Add a `debian12` OS/image profile for `target=qemu` in the provisioning interface.
- [x] 2.2 Define pinned image source/version metadata for `Debian 12` (and checksum strategy if available).
- [x] 2.3 Document profile-specific defaults or required overrides (CPU/RAM/disk/network if any).

## 3. cloud-init Compatibility Validation

- [x] 3.1 Confirm `Debian 12` image supports cloud-init with hostname + SSH key injection.
- [x] 3.2 Validate static IP configuration works on qemu/libvirt for the selected image.
- [x] 3.3 Validate SSH reachability after first boot and capture any distro-specific differences.

## 4. Documentation and Handoff Notes

- [x] 4.1 Update `make help` / docs with the `debian12` profile selection example for qemu (when implemented).
- [x] 4.2 Document known limitations and follow-up needs for Docker bootstrap parity on `Debian 12`.
- [x] 4.3 Record test evidence (hostname, IP, SSH) for the qemu image profile.
