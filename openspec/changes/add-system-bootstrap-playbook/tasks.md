## 1. OpenSpec Contract

- [ ] 1.1 Confirmar que `system_bootstrap` es el entrypoint compuesto para bootstrap base.
- [ ] 1.2 Confirmar orden obligatorio de roles: `system_update` antes de `docker_git`.
- [ ] 1.3 Validar artefactos de cambio con `openspec validate add-system-bootstrap-playbook --strict`.

## 2. Playbook Implementation

- [ ] 2.1 Crear `deployment/ansible/playbooks/system_bootstrap.yml`.
- [ ] 2.2 Incluir ambos roles en una misma ejecución con orden `system_update` -> `docker_git`.
- [ ] 2.3 Asegurar que `hosts`, `gather_facts` y `become` mantienen el contrato de los playbooks base.

## 3. Documentation and Validation

- [ ] 3.1 Actualizar `deployment/ansible/README.md` con el uso de `system_bootstrap`.
- [ ] 3.2 Actualizar checks de `deployment-ansible-syntax` y `deployment-ansible-lint` para incluir el nuevo playbook.
- [ ] 3.3 Extender smoke tests de ansible para cubrir sintaxis/lint del playbook compuesto.

## 4. Validation and Handoff

- [ ] 4.1 Re-ejecutar `openspec validate add-system-bootstrap-playbook --strict`.
- [ ] 4.2 Revisar coherencia final entre spec, tareas y archivos implementados.

