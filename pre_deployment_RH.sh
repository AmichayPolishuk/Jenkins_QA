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
yum-config-manager --disable rhel-7-fast-datapath-rpms
yum update -y
yum install -y lvm2 tigervnc

# Enable & Restart lvm
/sbin/service lvm2-lvmetad start
/sbin/service lvm2-lvmetad status


# Install GA OFED
build=last_release /mswg/release/MLNX_OFED/mlnx_ofed_install --hypervisor --add-kernel-support --force-fw-update --enable-sriov --force

# Unload the ib_isert, xprtrdma, ib_srpt module, and then restart openibd
modprobe -r ib_isert xprtrdma ib_srpt

# Restart HCA
/etc/init.d/openibd restart


# Add "intel_iommu=on" to kernel params
sed -i '/kernel/s/$/ intel_iommu=on /' /boot/grub/grub.conf
sed -i '/kernel/s/$/ intel_iommu=on /' /boot/grub/menu.lst
exit 0
