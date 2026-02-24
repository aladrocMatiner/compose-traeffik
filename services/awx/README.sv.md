[English](README.md) | [Svenska](README.sv.md) | [Espanol](README.es.md)

# AWX-tjanst

<a id="overview"></a>
## Oversikt

AWX runs in a local `k3d` Kubernetes cluster via AWX Operator. Traefik from this repository provides the HTTPS edge route at `https://awx.<DEV_DOMAIN>`.

<a id="location"></a>
## Plats

- `services/awx/` (docs + Kubernetes templates)
- `services/awx/k8s/` (namespace/operator/AWX manifests)
- `scripts/awx-*.sh` (lifecycle scripts)

<a id="run"></a>
## Korning

```bash
make awx-bootstrap
make awx-k3d-up
make awx-up
make awx-status
make awx-admin-password
```

<a id="configuration"></a>
## Konfiguration

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

Nuvarande begransning (Helm-flodet har):
- `AWX_OPERATOR_NAMESPACE` maste vara samma som `AWX_NAMESPACE` (operatorn bevakar sin release-namespace i denna uppsattning).

<a id="ports"></a>
## Portar, natverk, volymer

- Public endpoint: `https://awx.<DEV_DOMAIN>` via Traefik
- Backend bridge: `host.docker.internal:<AWX_HOST_PORT_HTTP>` -> k3d node `NodePort` (`AWX_NODEPORT_HTTP`)
- No `services/awx/compose.yml` runtime file (hybrid module, Kubernetes-managed runtime)
- Traefik-upstream: `host.docker.internal:<AWX_HOST_PORT_HTTP>` pekar pa host-porten som mappar till AWX `NodePort` i k3d.
- Hall `AWX_HOST_PORT_HTTP` och `AWX_NODEPORT_HTTP` synkade om du inte medvetet separerar dem.
- Standard-timeouts i Traefik anvands initialt; justera Traefik om AWX login/API senare behovar langre timeouts.

<a id="security"></a>
## Sakerhetsnoter

- Prefer access via Traefik/TLS only.
- AWX bootstrap secrets are generated into `.env` and should not be committed.
- Keep `AWX_KUBECONFIG_PATH` under a gitignored local path (default `.local/`).

<a id="troubleshooting"></a>
## Felsokning

- Validate tooling exists: `docker`, `k3d`, `kubectl`, `helm`
- Validate env: `./scripts/validate-awx-env.sh`
- Check cluster and pods: `make awx-status`
- Re-render Traefik dynamic config: `AWX_ENABLED=true ./scripts/traefik-render-dynamic.sh`

<a id="runtime-checklist"></a>
## Runtime-checklista

- `make awx-bootstrap`
- `make awx-k3d-up`
- `make awx-up`
- `make awx-status` tills `awx-web` och `awx-task` ar `Running` (forsta migrationsjobbet kan ta flera minuter)
- `make awx-admin-password`
- Kontrollera att Traefik kor (`make up` eller starta om `traefik` efter AWX-rendering)
- Test via Traefik: `curl -skI --resolve awx.<DEV_DOMAIN>:443:127.0.0.1 https://awx.<DEV_DOMAIN>/`
- Sakra lokal namnupplosning for `awx.<DEV_DOMAIN>` (lagg till `awx` i `ENDPOINTS` + hosts-flodet vid behov)

<a id="related"></a>
## Relaterade sidor

- [Root README](../../README.sv.md)
- [Traefik](../traefik/README.sv.md)
