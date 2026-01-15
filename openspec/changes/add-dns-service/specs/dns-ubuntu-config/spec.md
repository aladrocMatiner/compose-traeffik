## ADDED Requirements
### Requirement: Ubuntu split-DNS configuration
The system SHALL configure Ubuntu 24.04 to resolve `*.${BASE_DOMAIN}` via the local DNS server using systemd-resolved split-DNS.

#### Scenario: Apply configuration
- **WHEN** dns-configure-ubuntu.sh apply is executed
- **THEN** resolvectl is used to set DNS and domain routing for the default interface

#### Scenario: Remove configuration
- **WHEN** dns-configure-ubuntu.sh remove is executed
- **THEN** resolvectl settings for the project domain are removed without overwriting `/etc/resolv.conf`

#### Scenario: Dry-run output
- **WHEN** dns-configure-ubuntu.sh is run with --dry-run
- **THEN** intended resolvectl commands are printed and no changes are made
