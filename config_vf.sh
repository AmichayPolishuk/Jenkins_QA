#!/bin/bash

# Debug Session
if [ ${DEBUG_TRACE:-0} -gt 0 ]; then
    set -x
fi

# Error Handling
set -eu
set -o pipefail

# OFED must be installed
if [ -z "$(ofed_info -s)" ]; then
    exit 1
fi

HCA=$(ibstat -l | head -1)
FABRIC_TYPE=$(ibstat $HCA 1 | grep layer | cut -d' ' -f3)

# ConnectX-3 
if [ -n "$(lspci | grep ConnectX-3)" ]; then

    # OFED must be installed
    if [ -z "$(ofed_info -s)" ]; then
        exit 1
    fi
    if [ $FABRIC_TYPE == "Ethernet" ]; then
        HCA_BUS=$(lspci | grep nox | head -1 | cut -d':' -f1)
        # The following line will be inserted to /etc/modprobe.d/mlx4_core.conf
        ports_number=$(lspci | grep -c "\[ConnectX-3")
        if [ $ports_number == 1 ]; then
            CONF_LINE="options mlx4_core port_type_array=2 num_vfs=0000:$HCA_BUS:00.0-4;0;0 probe_vf=0000:$HCA_BUS:00.0-4;0;0 enable_64b_cqe_eqe=0 log_num_mgm_entry_size=-1 enable_vfs_qos=1"
        fi
        if [ $ports_number == 2 ]; then
            CONF_LINE="options mlx4_core port_type_array=2,2 num_vfs=0000:$HCA_BUS:00.0-4;0;0 probe_vf=0000:$HCA_BUS:00.0-4;0;0 enable_64b_cqe_eqe=0 log_num_mgm_entry_size=-1 enable_vfs_qos=1"
        fi
        echo $CONF_LINE > /etc/modprobe.d/mlx4_core.conf
        echo "successfully configured modprobe file"
        exit 0
    fi

    if [ $FABRIC_TYPE == "InfiniBand" ]; then
        # The following line will be inserted to /etc/modprobe.d/mlx4_core.conf
        CONF_LINE="options mlx4_core port_type_array=1,1 num_vfs=4 probe_vf=0 enable_64b_cqe_eqe=0 log_num_mgm_entry_size=-1"
        echo $CONF_LINE > /etc/modprobe.d/mlx4_core.conf
        # E_IPOIB_LOAD option in /etc/infiniband/openib.conf will be enabled
        sed -i  -e 's/E_IPOIB_LOAD=no/E_IPOIB_LOAD=yes/g' /etc/infiniband/openib.conf
        echo "successfully configured OFED rebooting host.."
        exit 0
    fi
    exit 1

elif [ -n  "$(lspci | grep ConnectX-4)" ]; then
    # Check crontab file existance
    if [ ! "$(crontab -l)" ]; then
        [ ! "$(crontab -l | { cat; echo ""; } | crontab - )"]
    fi
    
    # Check the Physical Port Number 
    ports_number=$(lspci | grep -c "\[ConnectX-4")
    if [ $ports_number == 1 ]; then
        crontab -l | { cat; echo "@reboot sleep 60 && echo 4 > /sys/class/infiniband/mlx5_0/device/sriov_numvfs"; } | crontab -
        exit 0
    fi

    if [ $ports_number == 2 ]; then
        crontab -l | { cat; echo "@reboot sleep 60 && echo 4 > /sys/class/infiniband/mlx5_0/device/sriov_numvfs"; } | crontab - 
        crontab -l | { cat; echo "@reboot sleep 60 && echo 4 > /sys/class/infiniband/mlx5_1/device/sriov_numvfs"; } | crontab - 
        exit 0
    fi

fi 
exit 1
