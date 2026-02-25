## Context
GitLab backups are more complex than stateless container exports. GitLab's backup command produces an application backup archive, but operators must also preserve configuration and secrets. NAS/NFS support is valuable as an off-host backup destination, but GitLab should not store live repository data on NFS.

## Goals
- Provide a safe, repeatable workflow for backup, restore, upgrade planning, and debug support.
- Support optional backup copy/upload to a NAS NFS share mounted on the host.
- Keep dangerous operations gated with explicit confirmations.
- Make the workflow clear enough for a medium-capability implementation agent.

## Non-Goals
- Automating NAS provisioning or NFS export creation on the NAS.
- Replacing offsite replication strategy (NAS is only one layer of resilience).
- Implementing HA or Geo replication.

## Day-2 Operation Model

### Backups
- Primary backup command runs inside GitLab Omnibus container (`gitlab-backup create`) using repo-managed scripts.
- Script stores metadata/manifests locally in a gitignored path (for example under `.local/gitlab/backups/`).
- Script also captures a separate backup artifact (or documented copy step) for GitLab config/secrets paths required for restore (for example `gitlab.rb` and `gitlab-secrets.json` from the mounted config volume).
- If NFS backup is enabled, the script copies or configures upload to a host-mounted NFS path as an additional destination.

### NFS backup target (optional)
- NFS mount is treated as a **host prerequisite** (mounted by OS/admin), not something the container auto-mounts itself.
- Compose binds the host mount path into the GitLab container only if needed for backup upload/copy workflows.
- Guardrails validate mountpoint path, non-empty export settings, host mount presence (for example via `findmnt` or equivalent), and that backup source and upload local root do not collide.

### Restore
- Restore is destructive to a running GitLab instance unless performed in an alternate target workflow.
- The repo scripts should require explicit confirmation (`--confirm`) and document a safe stop/restore/start sequence.
- Documentation must state version compatibility requirements (same GitLab version/edition for restore, unless following an official staged upgrade path).

### Upgrade
- `gitlab-upgrade` script/runbook focuses on a safe sequence (backup first, image tag bump, startup checks, rollback notes).
- The script may be a guarded helper/wrapper rather than full automation of every upgrade path.

### Debug
- Provide a repeatable support bundle of container status, logs, mounted config snapshot metadata, and GitLab health endpoints.

## Security Considerations
- NFS NAS improves host-loss resilience but is not a complete disaster recovery plan without snapshots/offsite replication.
- Backup scripts must document and/or capture GitLab config and secrets separately from the application backup tar.
- No credentials or secrets should be written to tracked files.
