## Context

AWX usa base de datos y componentes gestionados por operator, por lo que una integración local útil requiere procedimientos day-2 aunque el alcance sea de laboratorio. Este change separa esas operaciones del despliegue inicial para mantener el MVP implementable por un agente de complejidad media.

## Goals / Non-Goals

- Goals:
- Definir runbooks reproducibles para backup/restore/upgrade/debug de AWX en k3d.
- Establecer semántica de comandos Make/scripts y prerequisitos.
- Documentar riesgos de pérdida de datos y pasos de verificación post-restore/post-upgrade.

- Non-Goals:
- No introducir observabilidad Kubernetes completa (Prometheus/Loki) en este change.
- No soportar HA ni despliegues productivos multi-nodo.

## Decisions

- Decision: Separar day-2 operations del cambio de despliegue inicial AWX.
- Rationale: reduce riesgo y hace viable la implementación por etapas.

- Decision: Tratar backup/restore como procedimientos explícitos y validados, no automáticos por defecto.
- Rationale: evita falsa sensación de seguridad; AWX+Postgres requiere verificación real.

## Planned Day-2 Scope

- Recuperación segura de admin password / secretos (extendiendo y documentando el comando base del módulo AWX)
- Backup (mínimo: DB + metadata/config documentada)
- Restore con checklist de verificación
- Upgrade operator/AWX con pin de versiones y orden recomendado
- Debug/snapshot básico (`kubectl get`, `describe`, logs operator/web/task)

## Risks / Trade-offs

- Riesgo: procedimientos de backup incompletos si se asume solo base de datos.
- Mitigación: documentar explícitamente el alcance del backup y qué queda fuera (por ejemplo PVCs de proyectos si se habilitan).

- Riesgo: artefactos de backup acaben en rutas versionadas del repositorio.
- Mitigación: definir directorio de backups gitignored por defecto y documentar política de manejo de artefactos.

- Riesgo: upgrades rompan compatibilidad entre operator y AWX.
- Mitigación: pin de versiones, runbook de pre-checks, validación post-upgrade.
