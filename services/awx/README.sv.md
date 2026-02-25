[English](README.md) | [Svenska](README.sv.md) | [Espanol](README.es.md)

# AWX-tjanst

<a id="overview"></a>
## Oversikt

AWX kors i ett lokalt `k3d` Kubernetes-kluster via AWX Operator. Traefik i detta repo ger HTTPS-routen pa `https://awx.<DEV_DOMAIN>`.

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

Day-2-operationer (stateful underhall):

```bash
make awx-debug
make awx-backup
make awx-restore AWX_RESTORE_ARGS="--backup-name <awxbackup-cr> --confirm"
make awx-upgrade AWX_UPGRADE_ARGS="--confirm [--operator-chart-version <ver>] [--awx-version-target <ver>]"
```

<a id="configuration"></a>
## Konfiguration

Relevanta variabler i `.env.example`:
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

- Publik endpoint: `https://awx.<DEV_DOMAIN>` via Traefik
- Backend bridge: `host.docker.internal:<AWX_HOST_PORT_HTTP>` -> k3d node `NodePort` (`AWX_NODEPORT_HTTP`)
- Ingen `services/awx/compose.yml` for runtime (hybridmodul, runtime hanteras av Kubernetes)
- Traefik-upstream: `host.docker.internal:<AWX_HOST_PORT_HTTP>` pekar pa host-porten som mappar till AWX `NodePort` i k3d.
- Hall `AWX_HOST_PORT_HTTP` och `AWX_NODEPORT_HTTP` synkade om du inte medvetet separerar dem.
- Standard-timeouts i Traefik anvands initialt; justera Traefik om AWX login/API senare behovar langre timeouts.

<a id="security"></a>
## Sakerhetsnoter

- Anvand helst endast access via Traefik/TLS.
- AWX bootstrap-hemligheter genereras i `.env` och ska inte committas.
- Hall `AWX_KUBECONFIG_PATH` under en gitignored lokal sokvag (standard `.local/`).
- Hall `AWX_BACKUP_LOCAL_DIR` och `AWX_DEBUG_LOCAL_DIR` under `.local/` (gitignored).
- `awx-restore` och `awx-upgrade` kravs `--confirm`.

<a id="troubleshooting"></a>
## Felsokning

- Validera att verktyg finns: `docker`, `k3d`, `kubectl`, `helm`
- Validera env: `./scripts/validate-awx-env.sh`
- Kontrollera kluster och pods: `make awx-status`
- Rendera om Traefik dynamisk konfig: `AWX_ENABLED=true ./scripts/traefik-render-dynamic.sh`

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

<a id="day2-runbooks"></a>
## Day-2-runbooks (backup / restore / upgrade / debug)

- `make awx-backup`: skapar `AWXBackup` (operator) och sparar lokal metadata under `.local/awx/backups/` (CR/status + backupreferenser).
- Själva backup-payloaden ligger kvar i operatorns backup-PVC; scriptet exporterar inte payloaden ur klustret automatiskt.
- `make awx-restore AWX_RESTORE_ARGS="--backup-name <awxbackup-cr> --confirm"`: skapar `AWXRestore` och vantar pa `restoreComplete=true`.
- `make awx-upgrade AWX_UPGRADE_ARGS="--confirm ..."`: uppdaterar pins i `.env` (operator/AWX target) och applicerar AWX igen.
- `make awx-debug`: skapar lokal debug-bundle med snapshots/loggar.

Manuell checklista efter restore/upgrade:
- `make awx-status`
- `awx-web` / `awx-task` pods i `Running`
- UI/API via Traefik ar tillganglig (obs: restore till alternativ instans som `awxrestore` far inte automatiskt routen `awx.<DEV_DOMAIN>`)
- inloggning + enkel funktionskontroll

<a id="related"></a>
## Relaterade sidor

- [Root README](../../README.sv.md)
- [Traefik](../traefik/README.sv.md)
