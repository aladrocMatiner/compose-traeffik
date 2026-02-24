## ADDED Requirements
### Requirement: Kubernetes tooling wrappers are repo-driven
El sistema SHALL encapsular operaciones `k3d`, `kubectl` y `helm` del módulo AWX en scripts/targets del repositorio para reducir ambigüedad operativa.

#### Scenario: Operator runs AWX lifecycle via Make
- **WHEN** un operador usa `make awx-*`
- **THEN** las operaciones Kubernetes necesarias se ejecutan mediante scripts del repo
- **AND** los scripts aplican las mismas convenciones de entorno/documentación que el resto del proyecto

### Requirement: AWX scripts support env-file based execution
Los scripts operativos del módulo AWX SHALL soportar `--env-file` (o variable equivalente documentada) para alinearse con el resto de bootstrap/wrappers del repo.

#### Scenario: Alternate env file
- **WHEN** un operador ejecuta los scripts AWX con un archivo de entorno alternativo
- **THEN** la configuración del módulo AWX se resuelve desde ese archivo sin requerir edición manual de `.env`
