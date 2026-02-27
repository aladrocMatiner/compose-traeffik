## 1. OpenSpec Contract

- [ ] 1.1 Review and approve qemu image-profile scope for `Rocky Linux 9` (`vm-provisioning` only vs full bootstrap parity).
- [x] 1.2 Validate change artifacts with `openspec validate add-qemu-rockylinux9-image-support --strict`.

## 2. QEMU Image Profile Definition

- [x] 2.1 Add a `rockylinux9` OS/image profile for `target=qemu` in the provisioning interface.
- [x] 2.2 Define pinned image source/version metadata for `Rocky Linux 9` (and checksum strategy if available).
- [ ] 2.3 Document profile-specific defaults or required overrides (CPU/RAM/disk/network if any).

## 3. cloud-init Compatibility Validation

- [ ] 3.1 Confirm `Rocky Linux 9` image supports cloud-init with hostname + SSH key injection.
- [ ] 3.2 Validate static IP configuration works on qemu/libvirt for the selected image.
- [ ] 3.3 Validate SSH reachability after first boot and capture any distro-specific differences.

## 4. Documentation and Handoff Notes

- [x] 4.1 Update `make help` / docs with the `rockylinux9` profile selection example for qemu (when implemented).
- [ ] 4.2 Document known limitations and follow-up needs for Docker bootstrap parity on `Rocky Linux 9`.
- [ ] 4.3 Record test evidence (hostname, IP, SSH) for the qemu image profile.
