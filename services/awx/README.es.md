[English](README.md) | [Svenska](README.sv.md) | [Espanol](README.es.md)

# Servicio AWX

<a id="overview"></a>
## Resumen

AWX runs in a local `k3d` Kubernetes cluster via AWX Operator. Traefik from this repository provides the HTTPS edge route at `https://awx.<DEV_DOMAIN>`.

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

<a id="configuration"></a>
## Configuracion

Relevant variables in `.env.example`:
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

- Public endpoint: `https://awx.<DEV_DOMAIN>` via Traefik
- Backend bridge: `host.docker.internal:<AWX_HOST_PORT_HTTP>` -> k3d node `NodePort` (`AWX_NODEPORT_HTTP`)
- No `services/awx/compose.yml` runtime file (hybrid module, Kubernetes-managed runtime)
- Estrategia upstream en Traefik: `host.docker.internal:<AWX_HOST_PORT_HTTP>` apunta al puerto host mapeado al `NodePort` de AWX en k3d.
- Mantener `AWX_HOST_PORT_HTTP` y `AWX_NODEPORT_HTTP` alineados salvo desacople intencional.
- Se usan timeouts por defecto de Traefik; ajustar Traefik si mas adelante el login/API de AWX necesita timeouts mayores.

<a id="security"></a>
## Notas de seguridad

- Prefer access via Traefik/TLS only.
- AWX bootstrap secrets are generated into `.env` and should not be committed.
- Keep `AWX_KUBECONFIG_PATH` under a gitignored local path (default `.local/`).

<a id="troubleshooting"></a>
## Troubleshooting

- Validate tooling exists: `docker`, `k3d`, `kubectl`, `helm`
- Validate env: `./scripts/validate-awx-env.sh`
- Check cluster and pods: `make awx-status`
- Re-render Traefik dynamic config: `AWX_ENABLED=true ./scripts/traefik-render-dynamic.sh`

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

<a id="related"></a>
## Paginas relacionadas

- [Root README](../../README.es.md)
- [Traefik](../traefik/README.es.md)
