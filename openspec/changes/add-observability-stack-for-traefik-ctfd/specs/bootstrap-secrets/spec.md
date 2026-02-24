## MODIFIED Requirements
### Requirement: Persisted bootstrap secrets
El sistema MUST persistir en `.env` las credenciales usadas para generar archivos `htpasswd` y reutilizarlas en ejecuciones posteriores del bootstrap. Tambien MUST soportar bootstrap idempotente para secretos de modulos adicionales como observabilidad (por ejemplo credenciales de administrador de Grafana) mediante un comando dedicado (`make observability-bootstrap`).

#### Scenario: Bootstrap con secretos nuevos
- **WHEN** no existen valores de credenciales en `.env`
- **THEN** el bootstrap genera valores aleatorios seguros y los guarda en `.env`
- **AND** genera los archivos `htpasswd` con esos valores

#### Scenario: Bootstrap idempotente
- **WHEN** ya existen valores de credenciales en `.env`
- **THEN** el bootstrap no los sobrescribe sin un flag explicito
- **AND** re-genera los archivos `htpasswd` con los valores existentes

#### Scenario: Observability bootstrap idempotente
- **WHEN** se ejecuta `make observability-bootstrap` y ya existen secretos `GRAFANA_*` requeridos en `.env`
- **THEN** el comando conserva los valores existentes por defecto
- **AND** solo rota secretos con una accion explicita del operador
