#!/bin/bash
# Debug Session
if [ ${DEBUG_TRACE:-0} -gt 0 ]; then
    set -x
fi

# Error Handling
set -eu
set -o pipefail

echo ${public_interface_ip}

sudo ifconfig $public_interface $public_interface_ip/$(echo $floating_range | cut -d'/' -f2)
