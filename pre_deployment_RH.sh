#!/bin/bash

# Debug Session
if [ ${DEBUG_TRACE:-0} -gt 0 ]; then
    set -x
fi


# Error Handling
set -eu
set -o pipefail

# Install before OFED Installation
subscription-manager register --username openstack_mlnx --password openstack_mlnx_2015 --auto-attach
subscription-manager repos --enable rhel-7-server-optional-rpms
subscription-manager repos --enable rhel-7-server-extras-rpms 
yum update -y
yum install -y lvm2 tigervnc

# Enable & Restart lvm
/sbin/service lvm2-lvmetad start
/sbin/service lvm2-lvmetad status


# Install GA OFED
build=MLNX_OFED_LINUX-3.3-1.5.0.0 /mswg/release/MLNX_OFED/mlnx_ofed_install --hypervisor --add-kernel-support --force-fw-update --enable-sriov --force
# build=latest /mswg/release/MLNX_OFED/mlnx_ofed_install --hypervisor --add-kernel-support --force-fw-update --enable-sriov --force

# Restart HCA
/etc/init.d/openibd restart


# Add "intel_iommu=on" to kernel params
crudini --set /etc/default/grub '' grub_cmdline_linux "\"$(crudini --get /etc/default/grub '' grub_cmdline_linux | tr -d '"') intel_iommu=on\""
grub2-mkconfig -o /boot/grub2/grub.cfg
exit 0