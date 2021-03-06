#!/bin/bash

# Debug Session
if [ ${DEBUG_TRACE:-0} -gt 0 ]; then
    set -x
fi


# Error Handling
set -eu
set -o pipefail

# Check intel_iommu=on 
cat /proc/cmdline

# Check virtual functions existance
NUMBER_OF_VFS=$(lspci | grep "Virtual Function" | wc -l)

if [ -n "$NUMBER_OF_VFS" ]; then
    echo "Virtual Functions created successfully !"
    # Bring Up All Interfaces
    for port in `ibdev2netdev | cut -d' ' -f5`; do
        ifconfig $port up
    done
    exit 0 
else
    echo "Failed to create virtual functions !"
    exit 1
fi

