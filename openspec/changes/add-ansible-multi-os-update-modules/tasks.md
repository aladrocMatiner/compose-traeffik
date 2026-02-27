## 1. OpenSpec Contract

- [x] 1.1 Confirmar alcance multi-OS para los dos roles base en `deployment/ansible`.
- [x] 1.2 Validar lista de selectores soportados (`ubuntu`, `debian12`, `debian13`, `debian`, `gentoo`, `opensuse-leap`, `almalinux9`, `rockylinux9`, `fedora-cloud`) frente a la fuente de verdad de deployment.
- [x] 1.3 Validar artefactos de cambio con `openspec validate add-ansible-multi-os-update-modules --strict`.

## 2. Role: System Update

- [x] 2.1 Crear rol `deployment/ansible/roles/system_update` con `tasks/main.yml`.
- [x] 2.2 Implementar lógica por familia OS para refrescar metadata e instalar actualizaciones de paquetes.
- [x] 2.3 Garantizar idempotencia y soporte de `check_mode` cuando aplique.
- [x] 2.4 Exponer variables mínimas para controlar comportamiento (por ejemplo, update-only vs update+upgrade).

## 3. Role: Docker + Git

- [x] 3.1 Crear rol `deployment/ansible/roles/docker_git` con `tasks/main.yml`.
- [x] 3.2 Instalar `git` y `docker` para todas las familias soportadas usando paquetes apropiados por distribución.
- [x] 3.3 Asegurar que el servicio Docker queda habilitado/arrancado donde corresponda.
- [x] 3.4 Añadir validaciones/fallos explícitos para OS fuera de alcance.

## 4. Documentation and Tests

- [x] 4.1 Documentar uso de roles y variables en `deployment/ansible/README.md` (o ruta equivalente).
- [x] 4.2 Añadir pruebas de lint/syntax de Ansible para ambos roles.
- [x] 4.3 Añadir pruebas de smoke mínimas para verificar cobertura de selectores/familias y ejecución de syntax/lint.

## 5. Validation and Handoff

- [x] 5.1 Re-ejecutar `openspec validate add-ansible-multi-os-update-modules --strict`.
- [x] 5.2 Revisar coherencia final entre proposal, spec delta, tareas y rutas reales del repositorio.
