## ADDED Requirements

### Requirement: Wiki.js endpoint and TLS compatibility notes
The root documentation SHALL list the Wiki.js endpoint and describe its compatibility with the repo's Traefik TLS modes, including optional step-ca.

#### Scenario: Operator enables Wiki.js with step-ca
- **WHEN** the operator reads the root README and Wiki.js service docs
- **THEN** they can identify the Wiki.js hostname and lifecycle commands
- **AND** they can see that Wiki.js is routed by Traefik and uses the same selected TLS mode as the stack (including optional step-ca)
