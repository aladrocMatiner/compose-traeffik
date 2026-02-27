## 1. OpenSpec Contract

- [x] 1.1 Confirmar que `system_bootstrap` es el entrypoint compuesto para bootstrap base.
- [x] 1.2 Confirmar orden obligatorio de roles: `system_update` antes de `docker_git`.
- [x] 1.3 Validar artefactos de cambio con `openspec validate add-system-bootstrap-playbook --strict`.

## 2. Playbook Implementation

- [x] 2.1 Crear `deployment/ansible/playbooks/system_bootstrap.yml`.
- [x] 2.2 Incluir ambos roles en una misma ejecución con orden `system_update` -> `docker_git`.
- [x] 2.3 Asegurar que `hosts`, `gather_facts` y `become` mantienen el contrato de los playbooks base.

## 3. Documentation and Validation

- [x] 3.1 Actualizar `deployment/ansible/README.md` con el uso de `system_bootstrap`.
- [x] 3.2 Actualizar checks de `deployment-ansible-syntax` y `deployment-ansible-lint` para incluir el nuevo playbook.
- [x] 3.3 Extender smoke tests de ansible para cubrir sintaxis/lint del playbook compuesto y orden de roles.

## 4. Validation and Handoff

- [x] 4.1 Re-ejecutar `openspec validate add-system-bootstrap-playbook --strict`.
- [x] 4.2 Revisar coherencia final entre spec, tareas y archivos implementados.
