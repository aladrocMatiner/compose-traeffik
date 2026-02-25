## MODIFIED Requirements
### Requirement: Service layout under services/
The system SHALL organize each service under `services/<service>/` with a per-service README and, by default, a per-service compose file. For services whose upstream supported runtime is not Docker Compose (for example Kubernetes-operator-managed services), the repository MAY use a documented hybrid module layout under `services/<service>/` without a runtime `compose.yml`, provided the README explicitly documents the runtime model and operational entrypoints.

#### Scenario: Compose-managed service composition
- **WHEN** a user inspects a Compose-managed `services/<service>/`
- **THEN** it contains `compose.yml` and a `README.md` describing that service

#### Scenario: Hybrid module composition
- **WHEN** a user inspects a hybrid module under `services/<service>/`
- **THEN** it contains a `README.md` plus the runtime-specific configs/manifests/scripts for that service
- **AND** the README explains that the service is not launched via Docker Compose and names the supported Make/script entrypoints
