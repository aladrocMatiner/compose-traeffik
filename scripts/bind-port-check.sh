#!/bin/bash
# File: scripts/bind-port-check.sh
#
# Validate host port 53 is not already occupied by another DNS service.

set -euo pipefail

if ! command -v ss >/dev/null 2>&1; then
    echo "WARN: 'ss' command not found; skipping DNS port preflight check."
    exit 0
fi

LISTENERS=$(ss -ltnup '( sport = :53 )' 2>/dev/null | sed '/^Netid/d' || true)

if [ -z "${LISTENERS}" ]; then
    echo "INFO: DNS port preflight OK (host port 53 is free)."
    exit 0
fi

echo "ERROR: Host port 53 is already in use. BIND container cannot bind 53/tcp+udp."
echo
echo "Detected listeners:"
echo "${LISTENERS}"
echo
echo "Fix options:"
echo "  1) Stop host DNS service (named/bind9/systemd-resolved/dnsmasq/unbound)."
echo "  2) Or set BIND_BIND_ADDRESS in .env to an IP that is not already bound on :53."
echo
echo "Quick checks:"
echo "  sudo ss -ltnup '( sport = :53 )'"
echo "  sudo systemctl status named bind9 systemd-resolved dnsmasq unbound --no-pager"
echo
echo "Common stop commands:"
echo "  sudo systemctl stop named bind9 dnsmasq unbound"
echo "  sudo systemctl disable named bind9 dnsmasq unbound"
echo "  sudo systemctl stop systemd-resolved"
echo "  sudo systemctl disable systemd-resolved"
exit 1
