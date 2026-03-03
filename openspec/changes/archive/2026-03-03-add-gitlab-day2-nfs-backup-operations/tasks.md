## 1. Upstream Verification (Gate Before Coding)
- [ ] 1.1 Verify GitLab backup/restore command syntax and current Omnibus Docker workflow for the pinned GitLab version.
- [ ] 1.2 Verify official guidance for mounted share backups (`Local` provider / mounted NFS path) and backup path vs upload path collision caveat.
- [ ] 1.3 Verify restore prerequisites and version/edition compatibility notes to include in docs and guardrails.
- [ ] 1.4 Verify recommended health checks and post-restore validation steps.

## 2. Environment and Configuration Planning
- [ ] 2.1 Add `.env.example` variables for day-2 operations (backup root, retention, optional NFS toggles, NFS mountpoint/export metadata).
- [ ] 2.2 Define gitignored local artifact paths for backup manifests, debug bundles, and restore metadata.
- [ ] 2.3 Define host prerequisite documentation for mounting NFS on the host (not as Git repo primary storage).
- [ ] 2.4 Define a gitignored destination and retention policy for separate GitLab config/secrets backup artifacts (outside the app backup tar).

## 3. Script and Makefile Contracts
- [ ] 3.1 Add `make gitlab-backup`, `gitlab-restore`, `gitlab-upgrade`, `gitlab-debug` targets.
- [ ] 3.2 Implement `scripts/gitlab-backup.sh` with optional NFS destination path handling, metadata generation, and a documented copy/archive step for GitLab config/secrets needed for restore.
- [ ] 3.3 Implement `scripts/gitlab-restore.sh` with explicit `--confirm` requirement and pre/post checks.
- [ ] 3.4 Implement `scripts/gitlab-upgrade.sh` as a guarded workflow helper (backup precheck, version pin checks, rollout guidance).
- [ ] 3.5 Implement `scripts/gitlab-debug.sh` to collect status/logs/health and write to a gitignored output directory.

## 4. Guardrails and Safety Checks
- [ ] 4.1 Extend `scripts/validate-env.sh` (profile-gated) with GitLab day-2 validation for backup paths and optional NFS settings.
- [ ] 4.2 Validate NFS settings only when `GITLAB_BACKUP_NFS_ENABLED=true`.
- [ ] 4.3 Validate that the configured NFS backup mountpoint exists and is actually mounted on the host before attempting NFS backup copy/upload.
- [ ] 4.4 Reject unsafe path collisions (backup source path equals NFS upload local root) and obviously unsafe tracked destinations.
- [ ] 4.5 Require confirmation flags for restore/upgrade operations and test those guards.

## 5. Tests
- [ ] 5.1 Add smoke test for day-2 make target wiring (`test_gitlab_day2_make_targets.sh`).
- [ ] 5.2 Add smoke test for confirmation guards (`test_gitlab_day2_confirmation.sh`).
- [ ] 5.3 Add smoke test for NFS settings guardrails (`test_gitlab_nfs_backup_guardrails.sh`).
- [ ] 5.4 Document manual runtime backup/restore validation steps (including NAS/NFS path verification).

## 6. Documentation
- [ ] 6.1 Update `services/gitlab/README*.md` with backup/restore/upgrade/debug runbooks.
- [ ] 6.2 Document optional NFS/NAS backup destination setup, limitations, and disaster-recovery caveats.
- [ ] 6.3 Document that GitLab app backups do not cover all data classes (for example external object storage) and list what must be backed up separately.
- [ ] 6.4 Update root `README*.md` with GitLab day-2 command references.
- [ ] 6.5 Update `scripts/README.md` and `tests/README.md` inventories and examples.

## 7. Validation and Handoff
- [ ] 7.1 Run `openspec validate add-gitlab-day2-nfs-backup-operations --strict`.
- [ ] 7.2 Run `make docs-check`.
- [ ] 7.3 Run GitLab day-2 smoke tests.
- [ ] 7.4 Perform manual backup/restore dry run or documented runtime validation where environment permits.
