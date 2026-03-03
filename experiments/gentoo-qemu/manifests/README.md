# Manifests

Store pinned image metadata here (YAML or JSON), including:
- image source URL
- version/date pin
- checksum and checksum source
- architecture
- init system (`systemd` / `OpenRC`)
- cloud-init support status
- known limitations

Project rule for this experimental track:
- The primary qualified baseline for Gentoo/qemu must be `OpenRC`.
- `systemd` manifests may be recorded for comparison/fallback discovery and explicit `init=systemd` experimental runs, but are not the default baseline unless a future spec changes this.
