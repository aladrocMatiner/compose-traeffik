[English](README.md) | [Svenska](README.sv.md) | [Espanol](README.es.md)

# AWX service

<a id="overview"></a>
## Overview

AWX runs in a local `k3d` Kubernetes cluster via AWX Operator. Traefik from this repository provides the HTTPS edge route at `https://awx.<DEV_DOMAIN>`.

<a id="location"></a>
## Where it lives

- `services/awx/` (docs + Kubernetes templates)
- `services/awx/k8s/` (namespace/operator/AWX manifests)
- `scripts/awx-*.sh` (lifecycle scripts)

<a id="run"></a>
## How it runs

```bash
make awx-bootstrap
make awx-k3d-up
make awx-up
make awx-status
make awx-admin-password
```

<a id="configuration"></a>
## Configuration

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

Current limitation (Helm chart flow used here):
- `AWX_OPERATOR_NAMESPACE` must match `AWX_NAMESPACE` (operator watches its release namespace in this setup).

<a id="ports"></a>
## Ports, networks, volumes

- Public endpoint: `https://awx.<DEV_DOMAIN>` via Traefik
- Backend bridge: `host.docker.internal:<AWX_HOST_PORT_HTTP>` -> k3d node `NodePort` (`AWX_NODEPORT_HTTP`)
- No `services/awx/compose.yml` runtime file (hybrid module, Kubernetes-managed runtime)
- Traefik upstream strategy: `host.docker.internal:<AWX_HOST_PORT_HTTP>` targets the k3d host port mapped to AWX `NodePort`.
- Keep `AWX_HOST_PORT_HTTP` and `AWX_NODEPORT_HTTP` aligned unless you intentionally introduce a separate host port mapping.
- Traefik default timeouts are used initially; tune Traefik if AWX login/API traffic later needs longer proxy/server timeouts.

<a id="security"></a>
## Security notes

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
## Runtime validation checklist

- `make awx-bootstrap`
- `make awx-k3d-up`
- `make awx-up`
- `make awx-status` until `awx-web` and `awx-task` are `Running` (first boot migrations can take several minutes)
- `make awx-admin-password`
- Ensure Traefik is running (`make up` or restart `traefik` after rendering AWX route)
- Test via Traefik: `curl -skI --resolve awx.<DEV_DOMAIN>:443:127.0.0.1 https://awx.<DEV_DOMAIN>/`
- Ensure local name resolution for `awx.<DEV_DOMAIN>` (add `awx` to `ENDPOINTS` + hosts workflow if needed)

<a id="related"></a>
## Related pages

- [Root README](../../README.md)
- [Traefik](../traefik/README.md)
