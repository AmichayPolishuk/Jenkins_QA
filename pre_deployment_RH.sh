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
yum install -y kernel-devel redhat-rpm-config gcc rpm-build python-devel gcc-gfortran gtk2 tcsh tcl tk grub2-tools crudini


# Install GA OFED
build=MLNX_OFED_LINUX-3.2-2.0.0.0 /mswg/release/MLNX_OFED/mlnx_ofed_install --hypervisor --add-kernel-support --force-fw-update --enable-sriov --force
# build=latest /mswg/release/MLNX_OFED/mlnx_ofed_install --hypervisor --add-kernel-support --force-fw-update --enable-sriov --force

# Restart HCA
/etc/init.d/openibd restart


# Add "intel_iommu=on" to kernel params
crudini --set /etc/default/grub '' grub_cmdline_linux "\"$(crudini --get /etc/default/grub '' grub_cmdline_linux | tr -d '"') intel_iommu=on\""
grub2-mkconfig -o /etc/default/grub 

exit 0