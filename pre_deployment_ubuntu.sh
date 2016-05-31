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

# Update PCI Information 
sudo update-pciids

# Install GA OFED
build=3.2-2.0.0.0 /mswg/release/MLNX_OFED/mlnx_ofed_install --hypervisor --add-kernel-support --force-fw-update --enable-sriov --force
# build=latest /mswg/release/MLNX_OFED/mlnx_ofed_install --hypervisor --add-kernel-support --force-fw-update --enable-sriov --force

# Restart HCA
/etc/init.d/openibd restart

# Add "intel_iommu=on" to kernel params
sed -i '/kernel/s/$/ intel_iommu=on net.ifnames=0/' /boot/grub/grub.conf
sed -i '/kernel/s/$/ intel_iommu=on net.ifnames=0/' /boot/grub/menu.lst

exit 0
