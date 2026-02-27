## MODIFIED Requirements
### Requirement: Persisted bootstrap secrets
El sistema MUST persistir en `.env` las credenciales usadas para generar archivos `htpasswd` y reutilizarlas en ejecuciones posteriores del bootstrap. Tambien MUST soportar secretos del modulo CTFd generados por `make ctfd-bootstrap` (por ejemplo `CTFD_SECRET_KEY` y credenciales de base de datos/cache) con comportamiento idempotente por defecto.

#### Scenario: Bootstrap con secretos nuevos
- **WHEN** no existen valores de credenciales en `.env`
- **THEN** el bootstrap genera valores aleatorios seguros y los guarda en `.env`
- **AND** genera los archivos `htpasswd` con esos valores

#### Scenario: Bootstrap idempotente
- **WHEN** ya existen valores de credenciales en `.env`
- **THEN** el bootstrap no los sobrescribe sin un flag explicito
- **AND** re-genera los archivos `htpasswd` con los valores existentes

#### Scenario: CTFd bootstrap idempotente
- **WHEN** se ejecuta `make ctfd-bootstrap` y ya existen secretos `CTFD_*` requeridos en `.env`
- **THEN** el comando reutiliza los valores existentes por defecto
- **AND** solo rota secretos con una accion explicita del operador
