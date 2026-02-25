## MODIFIED Requirements

### Requirement: Preflight validation gate
The system SHALL execute preflight validation before any Docker Compose invocation and abort with a non-zero exit status when validation fails. The validation SHALL support profile-gated checks for optional modules such as GitLab.

#### Scenario: DNS target runs preflight
- **WHEN** a user runs `make dns-up`
- **THEN** preflight validation runs before Docker Compose is executed
- **AND** the command exits non-zero if validation fails

#### Scenario: GitLab target runs preflight
- **WHEN** a user runs `make gitlab-up`
- **THEN** preflight validation evaluates GitLab-specific checks only when the `gitlab` profile is enabled
- **AND** the command exits non-zero on invalid required GitLab configuration

### Requirement: Preflight documentation
Operational documentation SHALL describe preflight validation and the required environment variables for admin UI authentication. The documentation SHALL also describe service-specific preflight checks added for modules such as GitLab.

#### Scenario: Script documentation
- **WHEN** a user reads `scripts/README.md`
- **THEN** it lists `scripts/validate-env.sh` and the relevant htpasswd environment variables

#### Scenario: GitLab preflight guidance
- **WHEN** a user reads GitLab setup documentation and `scripts/README.md`
- **THEN** they can identify GitLab-specific preflight requirements such as SSH port format and OIDC-required variables when OIDC is enabled
