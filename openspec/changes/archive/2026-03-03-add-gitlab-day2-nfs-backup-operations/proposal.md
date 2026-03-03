# Change: Add GitLab Day-2 Operations with Optional NFS Backup Target

## Why
GitLab is stateful and backup/restore/upgrade procedures are critical. The user also needs a disaster-resilience path where backups can be copied to a NAS over NFS so source code is not lost if the GitLab host fails.

## What Changes
- Add documented and scripted day-2 operations for GitLab: backup, restore, upgrade planning, and debug collection.
- Add optional NFS/NAS backup destination support (host-mounted NFS share used as backup upload/copy target).
- Add guardrails and tests for safe operation (confirmation flags for destructive actions, path validation, NFS settings validation).
- Document constraints and caveats: Git repositories should not use NFS as primary storage, backup payload vs config/secrets, restore version compatibility.

## Impact
- Affected specs: `gitlab-day2-operations`, `guardrails`, `scripts-docs`, `tests-docs`
- Affected code: `scripts/gitlab-backup.sh`, `scripts/gitlab-restore.sh`, `scripts/gitlab-upgrade.sh`, `scripts/gitlab-debug.sh`, `Makefile`, docs, tests, optional helper docs under `services/gitlab/`

## Dependencies
- Requires `add-gitlab-service-module` to be implemented first (or concurrently) because day-2 operations target the GitLab module runtime and config layout.
