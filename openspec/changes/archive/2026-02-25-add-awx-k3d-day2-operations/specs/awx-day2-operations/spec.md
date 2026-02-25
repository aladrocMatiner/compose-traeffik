## ADDED Requirements
### Requirement: AWX day-2 runbooks are documented and reproducible
El sistema SHALL documentar runbooks reproducibles para operaciones day-2 del módulo AWX en k3d (al menos backup, restore, upgrade y debugging básico), con comandos del repo y prerequisitos explícitos.

#### Scenario: Operator follows backup runbook
- **WHEN** un operador sigue el runbook de backup AWX
- **THEN** ejecuta comandos concretos del repositorio y obtiene artefactos identificables de respaldo
- **AND** el runbook indica qué datos cubre y qué datos no cubre
- **AND** los artefactos se escriben por defecto en una ruta local documentada que no debe versionarse

#### Scenario: Operator follows upgrade runbook
- **WHEN** un operador sigue el runbook de upgrade AWX/operator
- **THEN** el procedimiento define el orden de pasos y verificaciones post-upgrade
- **AND** identifica riesgos y criterios de rollback o recuperación

### Requirement: Destructive AWX operations require explicit intent
Los comandos/scripts planificados para restore o acciones destructivas de AWX SHALL requerir una intención explícita (flag o confirmación documentada) para reducir errores operativos.

#### Scenario: Restore without explicit confirmation
- **WHEN** un operador invoca un comando de restore AWX sin el mecanismo de confirmación requerido
- **THEN** la operación no procede
- **AND** el comando informa cómo continuar de forma segura
