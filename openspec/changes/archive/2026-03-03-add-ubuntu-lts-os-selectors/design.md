# Design: Ubuntu LTS Versioned OS Selectors (20.04 / 22.04 / 24.04)

## Context

El provisioning actual usa `ubuntu` como perfil unico y descarga por defecto la imagen Noble (24.04). Para mantener reproducibilidad y facilitar pruebas de compatibilidad, necesitamos perfiles explicitos por version LTS sin romper el contrato existente.

La extension afecta dos capas:
- contrato de provision (`vm-provisioning`)
- discoverability de CLI (`deployment-list-os` y ayuda asociada)

## Goals / Non-Goals

- Goals:
  - incorporar selectores explicitos `ubuntu20.04`, `ubuntu22.04`, `ubuntu24.04`.
  - mantener `ubuntu` como alias retrocompatible y determinista.
  - pinnear metadata de imagenes Ubuntu LTS por selector.
  - mantener el flujo bootstrap apt-based para los selectores Ubuntu versionados.
- Non-Goals:
  - redisenar Terraform modules o cambiar arquitectura de target.
  - introducir soporte multi-plantilla Proxmox versionada en esta fase.
  - mezclar esta propuesta con cambios funcionales de deployment-project.

## Decisions

- Decision: usar selectores versionados explicitos en CLI.
  - Rationale: reduce ambiguedad sobre que release se provisiona realmente.

- Decision: conservar `ubuntu` como alias de `ubuntu24.04`.
  - Rationale: evita romper comandos y pipelines existentes.

- Decision: mantener validaciones de target estrictas y fail-fast.
  - Rationale: errores tempranos evitan provisionamientos parciales.

- Decision: tratar los perfiles Ubuntu versionados como familia `ubuntu` para bootstrap.
  - Rationale: se reutiliza la ruta apt existente sin duplicar logica.

## Risks / Trade-offs

- Riesgo: drift de URLs/checksums upstream.
  - Mitigacion: pinning explicito + verificacion checksum en flujo.

- Riesgo: confusion entre `ubuntu` y `ubuntu24.04`.
  - Mitigacion: documentar alias de forma explicita en `help` y docs.

- Riesgo: cobertura incompleta en scripts auxiliares.
  - Mitigacion: checklist de cambios cruzados + smoke tests de contrato de selectores.

## Migration Plan

1. Definir contrato OpenSpec para selectores Ubuntu LTS.
2. Implementar selectores y alias en scripts/Make.
3. Actualizar listados y documentacion.
4. Ajustar smoke tests de listados/guardrails de selector.
5. Validar comportamiento de alias y perfiles explicitos.

## Open Questions

- Confirmar nomenclatura final de selector (`ubuntu20.04` vs `ubuntu2004`) para balancear claridad y ergonomia en CLI.
- Confirmar si el comando discovery debe listar tambien el alias `ubuntu` ademas de los perfiles versionados.
