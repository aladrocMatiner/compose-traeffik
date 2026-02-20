## REMOVED Requirements

### Requirement: Ubuntu split-DNS configuration
**Reason**: The branch no longer ships the Technitium-specific `dns-configure-ubuntu.sh` workflow.
**Migration**: Configure system resolution using hosts or local resolver policies outside this branch, and use BIND operations documented in `docs/06-howto/service-dns-bind.md`.
