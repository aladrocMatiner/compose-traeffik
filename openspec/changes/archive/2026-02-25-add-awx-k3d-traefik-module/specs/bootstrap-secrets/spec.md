## MODIFIED Requirements
### Requirement: Persisted bootstrap secrets
El sistema MUST persistir en `.env` las credenciales usadas para generar archivos `htpasswd` y reutilizarlas en ejecuciones posteriores del bootstrap. El mismo patron SHALL aplicarse a secretos bootstrap de modulos adicionales (por ejemplo AWX) cuando esos modulos definan credenciales iniciales gestionadas por scripts del repo.

#### Scenario: Bootstrap con secretos nuevos
- **WHEN** no existen valores de credenciales en `.env`
- **THEN** el bootstrap genera valores aleatorios seguros y los guarda en `.env`
- **AND** genera los archivos `htpasswd` con esos valores

#### Scenario: Bootstrap idempotente
- **WHEN** ya existen valores de credenciales en `.env`
- **THEN** el bootstrap no los sobrescribe sin un flag explicito
- **AND** re-genera los archivos `htpasswd` con los valores existentes

#### Scenario: Bootstrap de modulo AWX
- **WHEN** el operador ejecuta el bootstrap del modulo AWX y faltan credenciales iniciales (por ejemplo admin password o secret key)
- **THEN** el script genera valores seguros y los persiste en `.env`
- **AND** una segunda ejecucion reutiliza los mismos valores salvo que se solicite rotacion explicita
