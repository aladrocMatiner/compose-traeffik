## ADDED Requirements

### Requirement: FreeIPA profile enforces preflight contracts
The system SHALL enforce FreeIPA-specific preflight guardrails only when profile `freeipa` is enabled.

#### Scenario: Missing FreeIPA core secrets
- **WHEN** `COMPOSE_PROFILES` includes `freeipa` and required secrets are missing
- **THEN** preflight fails before compose execution with a clear error.

### Requirement: FreeIPA TLS mode contract is validated
The system SHALL validate `FREEIPA_TLS_MODE` against supported values and enforce resolver/profile compatibility.

#### Scenario: Unsupported TLS mode
- **WHEN** `FREEIPA_TLS_MODE` is not one of `local-ca`, `letsencrypt`, or `stepca-acme`
- **THEN** preflight fails with a contract violation message.

#### Scenario: StepCA mode without resolver contract
- **WHEN** `FREEIPA_TLS_MODE=stepca-acme` and neither `stepca` profile nor `TLS_CERT_RESOLVER=stepca-resolver` is active
- **THEN** preflight fails before compose execution.

### Requirement: FreeIPA optional integration contracts are validated
The system SHALL validate Keycloak and observability contracts when their toggles are enabled.

#### Scenario: Keycloak enabled with incomplete contract
- **WHEN** `FREEIPA_KEYCLOAK_ENABLED=true` and required Keycloak values are missing
- **THEN** preflight fails with a clear contract message.

#### Scenario: Observability enabled with incomplete contract
- **WHEN** `FREEIPA_OBSERVABILITY_ENABLED=true` and required observability values are missing
- **THEN** preflight fails with a clear contract message.
