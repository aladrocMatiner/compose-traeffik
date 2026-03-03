## ADDED Requirements

### Requirement: Rocket.Chat endpoint and TLS compatibility notes
The root documentation SHALL list the Rocket.Chat endpoint and describe its compatibility with the repo's Traefik TLS modes, including step-ca as an optional mode.

#### Scenario: Operator enables Rocket.Chat with step-ca
- **WHEN** the operator reads the root README and Rocket.Chat service docs
- **THEN** they can identify the Rocket.Chat hostname and lifecycle commands
- **AND** they see that Rocket.Chat is routed by Traefik and can use the same TLS mode selected for the stack (including optional step-ca)
