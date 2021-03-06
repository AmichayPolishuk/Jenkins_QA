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
sudo apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -y upgrade
sudo apt-get install -y sshpass
sudo apt-get install openvswitch-switch vncviewer -y


# Update PCI Information 
sudo update-pciids

# Install GA OFED
build=last_release /mswg/release/MLNX_OFED/mlnx_ofed_install --hypervisor --add-kernel-support --force-fw-update --enable-sriov --force

# Restart HCA
/etc/init.d/openibd restart

# Add "intel_iommu=on" to kernel params
sed -i '/kernel/s/$/ intel_iommu=on /' /boot/grub/grub.conf
sed -i '/kernel/s/$/ intel_iommu=on /' /boot/grub/menu.lst

exit 0
