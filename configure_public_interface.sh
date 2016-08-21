#!/bin/bash
# Debug Session
if [ ${DEBUG_TRACE:-0} -gt 0 ]; then
    set -x
fi

# Error Handling
set -eu
set -o pipefail

sudo cat > /etc/sysconfig/network-scripts/ifcfg-br-ex  << EOF
DEVICE=br-ex
BOOTPROTO=none
ONBOOT=yes
NETWORK=10.209.86.0
PREFIX=24
IPADDR=${public_interface_ip}
EOF
