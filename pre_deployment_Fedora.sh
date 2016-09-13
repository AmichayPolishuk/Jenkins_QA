#!/bin/bash

# Debug Session
if [ ${DEBUG_TRACE:-0} -gt 0 ]; then
    set -x
fi


# Error Handling
set -eu
set -o pipefail

# Install before OFED Installation
yum install createrepo -y 
yum update -y
yum install -y kernel-devel redhat-rpm-config gcc rpm-build python-devel gcc-gfortran gtk2 tcsh tcl tk grub2-tools crudini sshpass openvswitch
sudo dnf -y install libxslt-devel libxml2-devel postgresql-devel libevent-devel memcached screen genisoimage libffi-devel openssl-devel lvm2 

# Enable & Restart openvswitch and lvm
systemctl enable openvswitch.service
systemctl start openvswitch.service
systemctl status openvswitch.service
/sbin/service lvm2-lvmetad start
/sbin/service lvm2-lvmetad status


# Install GA OFED
build=last_release /mswg/release/MLNX_OFED/mlnx_ofed_install --hypervisor --add-kernel-support --force-fw-update --enable-sriov --force

# Restart HCA
/etc/init.d/openibd restart


# Add "intel_iommu=on" to kernel params
crudini --set /etc/default/grub '' grub_cmdline_linux "\"$(crudini --get /etc/default/grub '' grub_cmdline_linux | tr -d '"') intel_iommu=on\""
grub2-mkconfig -o /boot/grub2/grub.cfg
exit 0
