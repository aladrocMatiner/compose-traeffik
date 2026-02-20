## REMOVED Requirements

### Requirement: Deterministic DNS record provisioning
**Reason**: Technitium API provisioning is removed from this branch.
**Migration**: Use `scripts/bind-provision.sh` (`make bind-provision` / `make bind-provision-dry`) and the `dns-bind-provisioning` capability.
