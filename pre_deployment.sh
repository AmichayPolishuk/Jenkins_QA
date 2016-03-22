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

# Latest OFED install
/mswg/release/MLNX_OFED/latest/MLNX_OFED_LINUX-*-ubuntu14.04-x86_64/mlnxofedinstall --enable-sriov --force

# Add "intel_iommu=on" to kernel params
sed -i '/kernel/s/$/ intel_iommu=on/' /boot/grub/grub.conf

