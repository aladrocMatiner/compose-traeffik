#!/bin/bash
# File: deployment/tests/smoke/test_deployment_profile_metadata.sh
#
# Smoke test: Validate deployment image profile pinning/metadata wiring.
#
# Usage: ./deployment/tests/smoke/test_deployment_profile_metadata.sh
#
# Returns 0 on success, 1 on failure.
#

set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/../../../scripts/common.sh"

INFRA_SCRIPT="$SCRIPT_DIR/../../../deployment/scripts/infra-provision.sh"
OPENRC_MANIFEST="$SCRIPT_DIR/../../../experiments/gentoo-qemu/manifests/gentoo-openrc-stage3-hostkernel-20260222T170100Z.yaml"
SYSTEMD_MANIFEST="$SCRIPT_DIR/../../../experiments/gentoo-qemu/manifests/gentoo-systemd-stage3-hostkernel-20260222T170100Z.yaml"

if [ ! -f "$INFRA_SCRIPT" ]; then
    log_error "infra-provision script not found."
fi

check_command "grep"

# Verify pinned image URLs for non-Debian profiles (no floating latest aliases).
if ! grep -q "AlmaLinux-9-GenericCloud-9.7-20251118.x86_64.qcow2" "$INFRA_SCRIPT"; then
    log_error "AlmaLinux profile is not pinned to a versioned image."
fi
if ! grep -q "Rocky-9-GenericCloud-9.7-20251123.2.x86_64.qcow2" "$INFRA_SCRIPT"; then
    log_error "Rocky Linux profile is not pinned to a versioned image."
fi
if ! grep -q "Fedora-Cloud-Base-Generic.x86_64-41-1.4.qcow2" "$INFRA_SCRIPT"; then
    log_error "Fedora Cloud profile pinning is missing."
fi

# Verify checksum policies for all qemu profile families.
for token in \
    DEPLOYMENT_OPENSUSE_LEAP_IMAGE_SHA256 \
    DEPLOYMENT_ALMALINUX9_IMAGE_SHA256 \
    DEPLOYMENT_ROCKYLINUX9_IMAGE_SHA256 \
    DEPLOYMENT_FEDORA_CLOUD_IMAGE_SHA256 \
    DEPLOYMENT_DEBIAN12_IMAGE_SHA512 \
    DEPLOYMENT_DEBIAN13_IMAGE_SHA512; do
    if ! grep -q "$token" "$INFRA_SCRIPT"; then
        log_error "Missing checksum token in infra-provision: ${token}"
    fi
done

# Gentoo manifests must exist and include explicit qemu qualification flags.
for manifest in "$OPENRC_MANIFEST" "$SYSTEMD_MANIFEST"; do
    if [ ! -f "$manifest" ]; then
        log_error "Missing Gentoo manifest: ${manifest}"
    fi
    if ! grep -q "^qualified_qemu_provisioning: true" "$manifest"; then
        log_error "Gentoo manifest missing qemu qualification gate: ${manifest}"
    fi
done

if ! grep -q "validate_gentoo_manifest" "$INFRA_SCRIPT"; then
    log_error "infra-provision does not validate Gentoo manifests."
fi

log_success "Deployment profile metadata smoke test passed."
