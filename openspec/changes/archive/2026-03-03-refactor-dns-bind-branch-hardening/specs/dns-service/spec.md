## REMOVED Requirements

### Requirement: DNS service profile with secure UI
**Reason**: Technitium `dns` profile is intentionally removed from `dns-bind` to avoid dual-DNS drift.
**Migration**: Use `bind` profile and BIND service docs (`services/dns-bind/README.md`, `docs/06-howto/service-dns-bind.md`).

### Requirement: Domain convention defaults
**Reason**: The Technitium-specific DNS capability is retired from this branch.
**Migration**: Keep `PROJECT_NAME`/`BASE_DOMAIN` conventions, but route DNS runtime and docs through BIND capability specs.
