## 1. Scope and Upstream Verification

- [ ] 1.1 Verificar documentación oficial de upgrade de `awx-operator` y compatibilidad de versiones AWX/operator.
- [ ] 1.2 Verificar opciones soportadas de backup/restore relevantes para AWX operator en entorno local.
- [ ] 1.3 Definir alcance explícito de datos respaldados en el módulo AWX (DB, PVCs, secrets, manifests).

## 2. Day-2 Make/Scripts Contract (Plan)

- [ ] 2.1 Definir targets propuestos (extensión de `awx-admin-password` si aplica, más `awx-debug`, `awx-backup`, `awx-restore`, `awx-upgrade`).
- [ ] 2.2 Definir semántica segura (confirmaciones/flags para restore y operaciones destructivas).
- [ ] 2.3 Definir entradas/salidas de artefactos (directorios de backup gitignored, nombres de archivo, retención local).

## 3. Runbooks and Documentation Plan

- [ ] 3.1 Definir runbook de backup con prerequisitos, comandos, validación y limitaciones.
- [ ] 3.2 Definir runbook de restore con orden de pasos y verificación post-restore.
- [ ] 3.3 Definir runbook de upgrade (operator + AWX) con pre-checks y rollback/documented recovery path.
- [ ] 3.4 Definir guía de debugging/support bundle para incidencias de operator/pods.

## 4. Validation Plan

- [ ] 4.1 Definir pruebas manuales mínimas de backup/restore/upgrade para entorno local k3d.
- [ ] 4.2 Definir cómo se documentará el resultado de esas pruebas y gaps conocidos.
- [ ] 4.3 Validar artefactos OpenSpec (`openspec validate add-awx-k3d-day2-operations --strict`).
