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

Day-2 operations (stateful maintenance):

```bash
make awx-debug
make awx-backup
# restore and upgrade require explicit confirmation flags:
make awx-restore AWX_RESTORE_ARGS="--backup-name <awxbackup-cr> --confirm"
make awx-upgrade AWX_UPGRADE_ARGS="--confirm [--operator-chart-version <ver>] [--awx-version-target <ver>]"
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
- AWX day-2 local artifacts (`AWX_BACKUP_LOCAL_DIR`, `AWX_DEBUG_LOCAL_DIR`) should stay under gitignored `.local/`.
- `awx-restore` and `awx-upgrade` require explicit `--confirm`.

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

<a id="day2-runbooks"></a>
## Day-2 runbooks (backup / restore / upgrade / debug)

### Backup (operator-managed backup + local metadata bundle)

Prerequisites:
- AWX running on k3d (`make awx-status`)
- `kubectl` context points to the AWX k3d cluster (scripts validate this)

Command:
```bash
make awx-backup
```

What it does:
- Creates an `AWXBackup` custom resource (operator-managed backup)
- Waits for backup status fields (`backupClaim`, `backupDirectory`)
- Writes a local metadata bundle under `AWX_BACKUP_LOCAL_DIR` (default `.local/awx/backups/`)

Coverage / limits:
- Covered: operator-managed AWX backup payload in-cluster (backup PVC), plus local metadata bundle (CR/status, selected secret YAMLs, snapshots)
- Not covered by the local metadata bundle: raw backup payload exported out of cluster, external systems, and anything outside the operator backup scope

Post-backup checks:
- `make awx-status`
- `kubectl -n awx get awxbackup`
- Inspect the generated `BACKUP-METADATA.txt` under `.local/awx/backups/...`

### Restore (explicit confirmation required)

Recommended approach:
- Restore to a separate deployment name first (default target is `<AWX_INSTANCE_NAME>-restore`)

Commands:
```bash
# Restore from an in-cluster AWXBackup CR by name
make awx-restore AWX_RESTORE_ARGS="--backup-name <awxbackup-cr> --confirm"

# Or restore using a local metadata bundle (it contains the backup CR name)
make awx-restore AWX_RESTORE_ARGS="--from .local/awx/backups/<bundle-dir> --confirm"
```

Notes:
- The script creates an `AWXRestore` CR and waits for `status.restoreComplete=true`
- If restoring to the same deployment name as the live AWX instance, treat it as destructive and verify all inputs carefully

Post-restore validation checklist (manual):
- `make awx-status`
- Confirm restored pods are `Running` in `kubectl get pods -n awx`
- Verify AWX UI/API accessibility for the restored instance exposure path
- Log in and perform a basic UI/API sanity check (inventory/project visibility, simple job template launch if applicable)

### Upgrade (operator/AWX target pins)

Commands:
```bash
# Reapply with current pins (still requires explicit confirmation)
make awx-upgrade AWX_UPGRADE_ARGS="--confirm"

# Change operator chart / documented AWX target pin and reapply
make awx-upgrade AWX_UPGRADE_ARGS="--confirm --operator-chart-version 3.2.0 --awx-version-target 24.6.1"
```

Upgrade order:
1. Create a backup (`make awx-backup`)
2. Update pins / run `awx-upgrade`
3. Watch rollout (`make awx-status`)
4. Validate UI/API via Traefik

Rollback / recovery guidance:
- Preferred recovery path for local labs is restore from a known `AWXBackup` using `awx-restore`
- Keep the previous pin values recorded (the script logs old/new values)

### Debug / support bundle

Command:
```bash
make awx-debug
```

Bundle contents (best effort):
- AWX/backup/restore resources, pods/services snapshot
- Recent events
- Operator log tail
- AWX web/task log tails and pod descriptions (if pods exist)

<a id="related"></a>
## Related pages

- [Root README](../../README.md)
- [Traefik](../traefik/README.md)
