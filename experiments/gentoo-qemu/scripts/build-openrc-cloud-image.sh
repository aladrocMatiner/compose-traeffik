#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXPERIMENT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
REPO_ROOT="$(cd "${EXPERIMENT_ROOT}/../.." && pwd)"

usage() {
  cat <<'EOF'
Build a Gentoo OpenRC qcow2 image suitable for libvirt + cloud-init (NoCloud).

This is an experimental builder used by the qemu/libvirt provisioning path for:
  make deployment os=gentoo init=openrc

The image is built from a Gentoo stage3 OpenRC tarball and uses:
  - Gentoo userland (OpenRC + sysvinit)
  - cloud-init + openssh + sudo (installed via Gentoo binpkgs)
  - host kernel/initrd + host /lib/modules (pragmatic bootstrap for v1)
  - GRUB (installed into the image using host grub-install)

Usage:
  experiments/gentoo-qemu/scripts/build-openrc-cloud-image.sh [options]

Options:
  --output PATH           Output qcow2 path (default under infra/images/gentoo/openrc/)
  --work-dir PATH         Scratch directory (default: experiments/gentoo-qemu/work/build-openrc-cloud-image)
  --stage3-url URL        Gentoo stage3 OpenRC tarball URL
  --stage3-sha256 VALUE   Stage3 SHA256 (optional; fetched from URL if omitted)
  --image-size-gb N       Raw build image size in GB (default: 12)
  --force                 Rebuild even if output exists
  --keep-work             Keep work dir on success/failure (default: no)
  -h, --help              Show this help

Environment overrides:
  GENTOO_OPENRC_STAGE3_URL
  GENTOO_OPENRC_STAGE3_SHA256
  GENTOO_OPENRC_IMAGE_SIZE_GB
  GENTOO_OPENRC_HOST_KERNEL_VERSION
  GENTOO_OPENRC_HOST_VMLINUZ
  GENTOO_OPENRC_HOST_INITRD
  GENTOO_OPENRC_HOST_MODULES_DIR
EOF
}

log() {
  printf 'INFO: %s\n' "$*"
}

warn() {
  printf 'WARN: %s\n' "$*" >&2
}

die() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

check_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "Missing required command: $1"
}

run_root() {
  if [[ "${EUID}" -eq 0 ]]; then
    "$@"
  elif command -v sudo >/dev/null 2>&1; then
    sudo "$@"
  else
    die "This script requires root or sudo for disk/chroot operations"
  fi
}

RUN_ROOT_INTERACTIVE=()
if [[ "${EUID}" -eq 0 ]]; then
  RUN_ROOT_INTERACTIVE=()
else
  RUN_ROOT_INTERACTIVE=(sudo)
fi

ROOTFS_MOUNT=""
LOOP_DEV=""
WORK_DIR_DEFAULT="${EXPERIMENT_ROOT}/work/build-openrc-cloud-image"
WORK_DIR="${WORK_DIR_DEFAULT}"
KEEP_WORK=false
FORCE=false
IMAGE_SIZE_GB="${GENTOO_OPENRC_IMAGE_SIZE_GB:-12}"
OUTPUT_QCOW2="${REPO_ROOT}/infra/images/gentoo/openrc/gentoo-openrc-cloudinit-hostkernel.qcow2"

STAGE3_URL_DEFAULT="https://distfiles.gentoo.org/releases/amd64/autobuilds/20260222T170100Z/stage3-amd64-openrc-20260222T170100Z.tar.xz"
STAGE3_URL="${GENTOO_OPENRC_STAGE3_URL:-${STAGE3_URL_DEFAULT}}"
STAGE3_SHA256="${GENTOO_OPENRC_STAGE3_SHA256:-}"

HOST_KERNEL_VERSION="${GENTOO_OPENRC_HOST_KERNEL_VERSION:-$(uname -r)}"
HOST_VMLINUZ="${GENTOO_OPENRC_HOST_VMLINUZ:-/boot/vmlinuz-${HOST_KERNEL_VERSION}}"
HOST_INITRD="${GENTOO_OPENRC_HOST_INITRD:-/boot/initrd.img-${HOST_KERNEL_VERSION}}"
HOST_MODULES_DIR="${GENTOO_OPENRC_HOST_MODULES_DIR:-/lib/modules/${HOST_KERNEL_VERSION}}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --output)
      [[ $# -ge 2 ]] || die "--output requires a value"
      OUTPUT_QCOW2="$2"
      shift 2
      ;;
    --work-dir)
      [[ $# -ge 2 ]] || die "--work-dir requires a value"
      WORK_DIR="$2"
      shift 2
      ;;
    --stage3-url)
      [[ $# -ge 2 ]] || die "--stage3-url requires a value"
      STAGE3_URL="$2"
      shift 2
      ;;
    --stage3-sha256)
      [[ $# -ge 2 ]] || die "--stage3-sha256 requires a value"
      STAGE3_SHA256="$2"
      shift 2
      ;;
    --image-size-gb)
      [[ $# -ge 2 ]] || die "--image-size-gb requires a value"
      IMAGE_SIZE_GB="$2"
      shift 2
      ;;
    --force)
      FORCE=true
      shift
      ;;
    --keep-work)
      KEEP_WORK=true
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      die "Unknown argument: $1"
      ;;
  esac
done

fetch_stage3_sha256() {
  local url="$1"
  local sha_url="${url}.sha256"
  local line
  line="$(curl -fsSL "${sha_url}" | grep -E '^[0-9a-f]{64} ' | head -n1)"
  # Gentoo .sha256 files are usually "<sha256>  filename"
  printf '%s\n' "${line%% *}"
}

cleanup() {
  local exit_code=$?

  if [[ -n "${ROOTFS_MOUNT}" ]]; then
    for d in dev/pts dev proc sys run; do
      run_root umount -lf "${ROOTFS_MOUNT}/${d}" >/dev/null 2>&1 || true
    done
    run_root umount -lf "${ROOTFS_MOUNT}" >/dev/null 2>&1 || true
  fi

  if [[ -n "${LOOP_DEV}" ]]; then
    run_root losetup -d "${LOOP_DEV}" >/dev/null 2>&1 || true
  fi

  if [[ "${exit_code}" -eq 0 && "${KEEP_WORK}" != "true" ]]; then
    rm -rf "${WORK_DIR}"
  fi

  exit "${exit_code}"
}
trap cleanup EXIT

check_cmd curl
check_cmd sha256sum
check_cmd tar
check_cmd qemu-img
check_cmd losetup
check_cmd mkfs.ext4
check_cmd mount
check_cmd rsync
check_cmd chroot
check_cmd grub-install
check_cmd blkid

[[ -f "${HOST_VMLINUZ}" ]] || die "Host kernel image not found: ${HOST_VMLINUZ}"
[[ -f "${HOST_INITRD}" ]] || die "Host initrd not found: ${HOST_INITRD}"
[[ -d "${HOST_MODULES_DIR}" ]] || die "Host modules directory not found: ${HOST_MODULES_DIR}"

if [[ -f "${OUTPUT_QCOW2}" && "${FORCE}" != "true" ]]; then
  log "Output image already exists (use --force to rebuild): ${OUTPUT_QCOW2}"
  exit 0
fi

STAGE3_SHA256="${STAGE3_SHA256:-$(fetch_stage3_sha256 "${STAGE3_URL}")}"
[[ -n "${STAGE3_SHA256}" ]] || die "Unable to determine stage3 sha256"

mkdir -p "${WORK_DIR}/cache" "${WORK_DIR}/mnt" "$(dirname "${OUTPUT_QCOW2}")"
STAGE3_TAR="${WORK_DIR}/cache/$(basename "${STAGE3_URL}")"
RAW_IMG="${WORK_DIR}/gentoo-openrc.raw"
ROOTFS_MOUNT="${WORK_DIR}/mnt"
CHROOT_SCRIPT="${WORK_DIR}/provision-chroot.sh"
STAGE3_SHA_FILE="${STAGE3_TAR}.sha256.local"

if [[ ! -f "${STAGE3_TAR}" ]]; then
  log "Downloading Gentoo stage3 OpenRC: ${STAGE3_URL}"
  curl -fL "${STAGE3_URL}" -o "${STAGE3_TAR}"
else
  log "Using cached stage3 tarball: ${STAGE3_TAR}"
fi

printf '%s  %s\n' "${STAGE3_SHA256}" "${STAGE3_TAR}" >"${STAGE3_SHA_FILE}"
sha256sum -c "${STAGE3_SHA_FILE}"

log "Creating raw build image (${IMAGE_SIZE_GB}G): ${RAW_IMG}"
rm -f "${RAW_IMG}"
truncate -s "${IMAGE_SIZE_GB}G" "${RAW_IMG}"

LOOP_DEV="$(run_root losetup --find --show "${RAW_IMG}")"
log "Loop device: ${LOOP_DEV}"

run_root mkfs.ext4 -F -L gentoo-root "${LOOP_DEV}" >/dev/null
run_root mount "${LOOP_DEV}" "${ROOTFS_MOUNT}"

log "Extracting stage3 into rootfs"
run_root tar xpf "${STAGE3_TAR}" -C "${ROOTFS_MOUNT}" --xattrs-include='*.*' --numeric-owner

log "Copying host kernel/initrd/modules into image (kernel=${HOST_KERNEL_VERSION})"
run_root mkdir -p "${ROOTFS_MOUNT}/boot" "${ROOTFS_MOUNT}/lib/modules"
run_root install -m 0644 "${HOST_VMLINUZ}" "${ROOTFS_MOUNT}/boot/vmlinuz-${HOST_KERNEL_VERSION}"
run_root install -m 0644 "${HOST_INITRD}" "${ROOTFS_MOUNT}/boot/initrd.img-${HOST_KERNEL_VERSION}"
run_root rsync -aHAX --delete "${HOST_MODULES_DIR}/" "${ROOTFS_MOUNT}/lib/modules/${HOST_KERNEL_VERSION}/"

ROOT_UUID="$(run_root blkid -s UUID -o value "${LOOP_DEV}")"
[[ -n "${ROOT_UUID}" ]] || die "Failed to detect filesystem UUID for ${LOOP_DEV}"

log "Writing base Gentoo configs"
run_root mkdir -p "${ROOTFS_MOUNT}/etc" "${ROOTFS_MOUNT}/etc/cloud/cloud.cfg.d" "${ROOTFS_MOUNT}/boot/grub"

cat <<EOF | run_root tee "${ROOTFS_MOUNT}/etc/fstab" >/dev/null
UUID=${ROOT_UUID}  /      ext4  defaults,noatime  0 1
tmpfs              /tmp   tmpfs nosuid,nodev      0 0
EOF

cat <<'EOF' | run_root tee "${ROOTFS_MOUNT}/etc/cloud/cloud.cfg.d/90_nocloud-compose-traeffik.cfg" >/dev/null
datasource_list: [ NoCloud, None ]
network:
  config: disabled
EOF

cat <<'EOF' | run_root tee "${ROOTFS_MOUNT}/etc/hosts" >/dev/null
127.0.0.1 localhost
::1 localhost
EOF

cat <<'EOF' | run_root tee "${ROOTFS_MOUNT}/etc/hostname" >/dev/null
gentoo-openrc
EOF

# Ensure serial console login for debugging on libvirt console.
if ! run_root grep -q 'ttyS0' "${ROOTFS_MOUNT}/etc/inittab"; then
  echo 's0:12345:respawn:/sbin/agetty 115200 ttyS0 vt100' | run_root tee -a "${ROOTFS_MOUNT}/etc/inittab" >/dev/null
fi

run_root cp /etc/resolv.conf "${ROOTFS_MOUNT}/etc/resolv.conf"

for d in proc sys dev dev/pts run; do
  run_root mkdir -p "${ROOTFS_MOUNT}/${d}"
done
run_root mount --bind /proc "${ROOTFS_MOUNT}/proc"
run_root mount --bind /sys "${ROOTFS_MOUNT}/sys"
run_root mount --bind /dev "${ROOTFS_MOUNT}/dev"
run_root mount --bind /dev/pts "${ROOTFS_MOUNT}/dev/pts"
run_root mount --bind /run "${ROOTFS_MOUNT}/run"

cat >"${CHROOT_SCRIPT}" <<'CHROOT'
#!/bin/bash
set -eo pipefail

export DEBUGINFOD_URLS="${DEBUGINFOD_URLS-}"
export DEBUGINFOD_IMA_CERT_PATH="${DEBUGINFOD_IMA_CERT_PATH-}"
source /etc/profile || true

mkdir -p /etc/portage/repos.conf
if [[ -f /usr/share/portage/config/repos.conf ]]; then
  cp -n /usr/share/portage/config/repos.conf /etc/portage/repos.conf/gentoo.conf || true
fi

if [[ ! -f /var/db/repos/gentoo/profiles/repo_name ]]; then
  emerge-webrsync
fi

if [[ -f /etc/portage/binrepos.conf/gentoobinhost.conf ]]; then
  sed -i 's/^verify-signature = true$/verify-signature = false/' /etc/portage/binrepos.conf/gentoobinhost.conf || true
fi

# Install only what we need for ansible-ready cloud bootstrap.
emerge --getbinpkgonly --usepkgonly --oneshot \
  net-misc/openssh \
  app-emulation/cloud-init \
  app-admin/sudo

mkdir -p /etc/cloud/cloud.cfg.d /etc/sudoers.d

# OpenRC service wiring for cloud-init + sshd.
rc-update add sshd default
for svc in cloud-init-local cloud-init cloud-config cloud-final; do
  if [[ -x "/etc/init.d/${svc}" ]]; then
    if [[ "${svc}" == "cloud-init-local" ]]; then
      rc-update add "${svc}" boot
    else
      rc-update add "${svc}" default
    fi
  fi
done

# cloud-init creates per-user sudoers entries, but enabling wheel NOPASSWD keeps manual recovery simple.
if [[ ! -f /etc/sudoers.d/90-compose-traeffik-wheel-nopasswd ]]; then
  printf '%%wheel ALL=(ALL) NOPASSWD:ALL\n' >/etc/sudoers.d/90-compose-traeffik-wheel-nopasswd
  chmod 0440 /etc/sudoers.d/90-compose-traeffik-wheel-nopasswd
fi

# Ensure root account isn't password-login friendly by default.
passwd -l root || true

# Reset machine/cloud state for cloning.
cloud-init clean --logs --machine-id || true
rm -rf /var/lib/cloud/*
truncate -s 0 /etc/machine-id || true
CHROOT

chmod +x "${CHROOT_SCRIPT}"
run_root cp "${CHROOT_SCRIPT}" "${ROOTFS_MOUNT}/tmp/provision-chroot.sh"

log "Provisioning Gentoo packages and OpenRC services inside chroot (binpkg-only)"
"${RUN_ROOT_INTERACTIVE[@]}" chroot "${ROOTFS_MOUNT}" /bin/bash /tmp/provision-chroot.sh
run_root rm -f "${ROOTFS_MOUNT}/tmp/provision-chroot.sh"

log "Installing GRUB bootloader into image using host grub-install"
run_root grub-install \
  --target=i386-pc \
  --boot-directory="${ROOTFS_MOUNT}/boot" \
  --recheck \
  --force \
  "${LOOP_DEV}"

cat <<EOF | run_root tee "${ROOTFS_MOUNT}/boot/grub/grub.cfg" >/dev/null
set default=0
set timeout=0

menuentry 'Gentoo OpenRC (host-kernel bootstrap)' {
  linux /boot/vmlinuz-${HOST_KERNEL_VERSION} root=UUID=${ROOT_UUID} ro console=tty0 console=ttyS0,115200n8
  initrd /boot/initrd.img-${HOST_KERNEL_VERSION}
}
EOF

sync
run_root sync

log "Converting raw image to qcow2: ${OUTPUT_QCOW2}"
rm -f "${OUTPUT_QCOW2}"
qemu-img convert -f raw -O qcow2 "${RAW_IMG}" "${OUTPUT_QCOW2}"
qemu-img info "${OUTPUT_QCOW2}"

log "Gentoo OpenRC cloud-init image build complete"
log "Output: ${OUTPUT_QCOW2}"
