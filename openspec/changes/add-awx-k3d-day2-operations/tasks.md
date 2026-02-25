## 1. Scope and Upstream Verification

- [x] 1.1 Verificar documentación oficial de upgrade de `awx-operator` y compatibilidad de versiones AWX/operator. *(Se mantiene pin de chart/operator y runbook de upgrade con pines en `.env`; referencias oficiales en la propuesta y docs del módulo.)*
- [x] 1.2 Verificar opciones soportadas de backup/restore relevantes para AWX operator en entorno local. *(Implementación basada en CRDs `AWXBackup` / `AWXRestore` verificados vía `kubectl explain` contra el operator instalado.)*
- [x] 1.3 Definir alcance explícito de datos respaldados en el módulo AWX (DB, PVCs, secrets, manifests). *(`awx-backup` documenta cobertura: backup operator-managed en PVC + metadata local; límites explícitos.)*

## 2. Day-2 Make/Scripts Contract (Plan)

- [x] 2.1 Definir targets propuestos (extensión de `awx-admin-password` si aplica, más `awx-debug`, `awx-backup`, `awx-restore`, `awx-upgrade`).
- [x] 2.2 Definir semántica segura (confirmaciones/flags para restore y operaciones destructivas). *(`awx-restore` / `awx-upgrade` requieren `--confirm`; smoke test dedicado.)*
- [x] 2.3 Definir entradas/salidas de artefactos (directorios de backup gitignored, nombres de archivo, retención local). *(Artifacts en `.local/awx/backups` y `.local/awx/debug`; metadata bundles con nombres timestamped.)*

## 3. Runbooks and Documentation Plan

- [x] 3.1 Definir runbook de backup con prerequisitos, comandos, validación y limitaciones.
- [x] 3.2 Definir runbook de restore con orden de pasos y verificación post-restore.
- [x] 3.3 Definir runbook de upgrade (operator + AWX) con pre-checks y rollback/documented recovery path.
- [x] 3.4 Definir guía de debugging/support bundle para incidencias de operator/pods.

## 4. Validation Plan

- [x] 4.1 Definir pruebas manuales mínimas de backup/restore/upgrade para entorno local k3d.
- [x] 4.2 Definir cómo se documentará el resultado de esas pruebas y gaps conocidos. *(Runbooks + checklist manual en `services/awx/README*.md` y notas en `tests/README.md`.)*
- [x] 4.3 Validar artefactos OpenSpec (`openspec validate add-awx-k3d-day2-operations --strict`).
