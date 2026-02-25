## ADDED Requirements
### Requirement: Managed local k3d cluster lifecycle for AWX
El sistema SHALL proporcionar comandos/scripts para crear, destruir y consultar un clúster local `k3d` usado por el módulo AWX.

#### Scenario: Create cluster for AWX
- **WHEN** un operador ejecuta el target/script de creación de clúster AWX
- **THEN** se crea un clúster `k3d` con nombre configurable y configuración reproducible
- **AND** el clúster se prepara para desplegar AWX (incluyendo deshabilitar Traefik interno si así se define en el diseño)

#### Scenario: Destroy cluster explicitly
- **WHEN** un operador ejecuta el target/script de destrucción del clúster AWX
- **THEN** el clúster local `k3d` se elimina
- **AND** la operación se separa semánticamente del borrado de la instancia AWX para evitar destrucciones accidentales

### Requirement: Deterministic kubeconfig handling
El sistema SHALL usar una estrategia de `KUBECONFIG` explícita y documentada para las operaciones AWX/k3d del repositorio.

#### Scenario: Run kubectl through repo scripts
- **WHEN** un script AWX ejecuta `kubectl` o `helm`
- **THEN** usa un `KUBECONFIG` determinado por el entorno/configuración del repo
- **AND** valida que el contexto/cluster objetivo coincide con el clúster AWX esperado o falla con un mensaje claro
- **AND** muestra mensajes claros si el kubeconfig no existe o apunta a un clúster inesperado
