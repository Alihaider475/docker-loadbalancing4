#!/bin/sh

# Detect WSL2 / Docker Desktop (Windows or Mac) by checking the kernel version
KERNEL=$(uname -r)
if echo "$KERNEL" | grep -qi "microsoft\|wsl\|linuxkit"; then
    echo "[keepalived] Detected Docker Desktop environment (kernel: $KERNEL)"
    echo "[keepalived] VRRP virtual IP failover requires a bare-metal Linux host."
    echo "[keepalived] Running in standby mode - all other services are unaffected."
    echo "[keepalived] Deploy on a Linux server for full HA functionality."
    while true; do sleep 60; done
fi

# Fix config file permissions - keepalived refuses executable config files.
# Docker Desktop mounts Windows files with executable bits set by default.
CONFIG="/usr/local/etc/keepalived/keepalived.conf"
if [ -f "$CONFIG" ]; then
    chmod 644 "$CONFIG"
    echo "[keepalived] Config permissions set to 644"
fi

echo "[keepalived] Starting keepalived normally..."
exec /container/tool/run "$@"
