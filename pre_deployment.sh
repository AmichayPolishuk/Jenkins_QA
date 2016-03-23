#!/bin/bash

# Debug Session
if [ ${DEBUG_TRACE:-0} -gt 0 ]; then
    set -x
fi

# Error Handling
set -eu
set -o pipefail

# Update Cashe
sudo apt-get update

# Install GA OFED
/mswg/release/MLNX_OFED/MLNX_OFED_LINUX-3.2-2.0.0.0/MLNX_OFED_LINUX-3.2-2.0.0.0-ubuntu14.04-x86_64/mlnxofedinstall --enable-sriov --force

# Add "intel_iommu=on" to kernel params
sed -i '/kernel/s/$/ intel_iommu=on/' /boot/grub/grub.conf

exit 0
