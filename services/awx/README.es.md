[English](README.md) | [Svenska](README.sv.md) | [Espanol](README.es.md)

# Servicio AWX

<a id="overview"></a>
## Resumen

AWX se ejecuta en un cluster local `k3d` de Kubernetes mediante AWX Operator. Traefik de este repositorio proporciona la ruta HTTPS en `https://awx.<DEV_DOMAIN>`.

<a id="location"></a>
## Donde vive

- `services/awx/` (docs + Kubernetes templates)
- `services/awx/k8s/` (namespace/operator/AWX manifests)
- `scripts/awx-*.sh` (lifecycle scripts)

<a id="run"></a>
## Como corre

```bash
make awx-bootstrap
make awx-k3d-up
make awx-up
make awx-status
make awx-admin-password
```

Operaciones day-2 (mantenimiento con estado):

```bash
make awx-debug
make awx-backup
make awx-restore AWX_RESTORE_ARGS="--backup-name <awxbackup-cr> --confirm"
make awx-upgrade AWX_UPGRADE_ARGS="--confirm [--operator-chart-version <ver>] [--awx-version-target <ver>]"
```

<a id="configuration"></a>
## Configuracion

Variables relevantes en `.env.example`:
- `AWX_ENABLED`
- `AWX_HOSTNAME`
- `AWX_NAMESPACE`
- `AWX_INSTANCE_NAME`
- `AWX_K3D_CLUSTER_NAME`
- `AWX_KUBECONFIG_PATH`
- `AWX_NODEPORT_HTTP`
- `AWX_HOST_PORT_HTTP`
- `AWX_ADMIN_USER`
- `AWX_ADMIN_PASSWORD`
- `AWX_SECRET_KEY`
- `AWX_OPERATOR_*`
- `K3D_K3S_IMAGE`

Limitacion actual (flujo Helm usado aqui):
- `AWX_OPERATOR_NAMESPACE` debe coincidir con `AWX_NAMESPACE` (el operator observa su namespace de release en esta configuracion).

<a id="ports"></a>
## Puertos, redes, volumenes

- Endpoint publico: `https://awx.<DEV_DOMAIN>` via Traefik
- Backend bridge: `host.docker.internal:<AWX_HOST_PORT_HTTP>` -> k3d node `NodePort` (`AWX_NODEPORT_HTTP`)
- No existe `services/awx/compose.yml` para runtime (modulo hibrido, runtime gestionado por Kubernetes)
- Estrategia upstream en Traefik: `host.docker.internal:<AWX_HOST_PORT_HTTP>` apunta al puerto host mapeado al `NodePort` de AWX en k3d.
- Mantener `AWX_HOST_PORT_HTTP` y `AWX_NODEPORT_HTTP` alineados salvo desacople intencional.
- Se usan timeouts por defecto de Traefik; ajustar Traefik si mas adelante el login/API de AWX necesita timeouts mayores.

<a id="security"></a>
## Notas de seguridad

- Preferir acceso solo via Traefik/TLS.
- Los secretos de bootstrap de AWX se generan en `.env` y no deben versionarse.
- Mantener `AWX_KUBECONFIG_PATH` en una ruta local gitignored (por defecto `.local/`).
- Mantener `AWX_BACKUP_LOCAL_DIR` y `AWX_DEBUG_LOCAL_DIR` bajo `.local/` (gitignored).
- `awx-restore` y `awx-upgrade` requieren `--confirm`.

<a id="troubleshooting"></a>
## Troubleshooting

- Validar que existen herramientas: `docker`, `k3d`, `kubectl`, `helm`
- Validar env: `./scripts/validate-awx-env.sh`
- Revisar cluster y pods: `make awx-status`
- Re-render de config dinamica de Traefik: `AWX_ENABLED=true ./scripts/traefik-render-dynamic.sh`

<a id="runtime-checklist"></a>
## Checklist runtime

- `make awx-bootstrap`
- `make awx-k3d-up`
- `make awx-up`
- `make awx-status` hasta que `awx-web` y `awx-task` esten en `Running` (las migraciones iniciales pueden tardar varios minutos)
- `make awx-admin-password`
- Asegurar Traefik activo (`make up` o reiniciar `traefik` tras renderizar la ruta AWX)
- Probar via Traefik: `curl -skI --resolve awx.<DEV_DOMAIN>:443:127.0.0.1 https://awx.<DEV_DOMAIN>/`
- Asegurar resolucion local de `awx.<DEV_DOMAIN>` (anadir `awx` a `ENDPOINTS` + flujo hosts si hace falta)

<a id="day2-runbooks"></a>
## Runbooks day-2 (backup / restore / upgrade / debug)

- `make awx-backup`: crea un `AWXBackup` (operator) y guarda metadata local en `.local/awx/backups/` (incluye CR/status y referencias de backup PVC/directorio).
- El payload real del backup permanece en el PVC de backup gestionado por el operator; este script no lo exporta fuera del cluster automaticamente.
- `make awx-restore AWX_RESTORE_ARGS="--backup-name <awxbackup-cr> --confirm"`: crea un `AWXRestore` y espera `restoreComplete=true`.
- `make awx-upgrade AWX_UPGRADE_ARGS="--confirm ..."`: actualiza pines en `.env` (operator/AWX target) y reaplica AWX.
- `make awx-debug`: genera bundle local de diagnostico con snapshots/logs.

Checklist post-restore / post-upgrade (manual):
- `make awx-status`
- pods `awx-web` / `awx-task` en `Running`
- acceso UI/API via Traefik (ojo: un restore a una instancia alternativa como `awxrestore` no reutiliza automaticamente la ruta `awx.<DEV_DOMAIN>`)
- login y comprobacion funcional basica

<a id="related"></a>
## Paginas relacionadas

- [Root README](../../README.es.md)
- [Traefik](../traefik/README.es.md)
