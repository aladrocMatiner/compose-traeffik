## MODIFIED Requirements

### Requirement: Persisted bootstrap secrets
El sistema MUST persistir en `.env` las credenciales usadas para generar archivos `htpasswd` y reutilizarlas en ejecuciones posteriores del bootstrap. El mismo patrón MUST aplicarse a secretos de bootstrap de nuevos servicios como GitLab cuando se generen por script.

#### Scenario: Bootstrap con secretos nuevos
- **WHEN** no existen valores de credenciales en `.env`
- **THEN** el bootstrap genera valores aleatorios seguros y los guarda en `.env`
- **AND** genera los archivos `htpasswd` con esos valores

#### Scenario: Bootstrap idempotente
- **WHEN** ya existen valores de credenciales en `.env`
- **THEN** el bootstrap no los sobrescribe sin un flag explicito
- **AND** re-genera los archivos `htpasswd` con los valores existentes

#### Scenario: GitLab bootstrap secrets
- **WHEN** `make gitlab-bootstrap` requires admin or OIDC-related secrets that are generated locally
- **THEN** the generated values are persisted in `.env` and reused on subsequent runs
- **AND** the script documents how to rotate them safely
