#!/bin/bash

# Debug Session
if [ ${DEBUG_TRACE:-0} -gt 0 ]; then
    set -x
fi

# Error Handling
set -eu
set -o pipefail

# Force Nic
FORCE_NIC=$(FORCE_NIC:-"")

# Number of VF's to bring up
NUM_OF_VFS=$(NUM_OF_VFS:-4)

# OFED must be installed
if [ -z "$(ofed_info -s)" ]; then
    exit 1
fi

MT=""
if [ ${FORCE_NIC} != "" ]; then
    case "${FORCE_NIC}" in
        CX4)
            MT=MT4115
            ;;
        CX3)
            MT=MT4103
            ;;
        LX)
            MT=MT4117
            ;;
    esac
fi

if [ ${MT} == "" ]; then
    HCA=$(sudo ibdev2netdev -v | head -1 | awk '{print $2}')
    HCA_BUS=$(sudo ibdev2netdev -v | head -1 | awk '{print $1}')
    MT=$(sudo ibdev2netdev -v | head -1 | awk '{print $3}' | cut -d'(' -f2)
else
    HCA=$(sudo ibdev2netdev -v | grep ${MT} | head -1 | awk '{print $2}')
    HCA_BUS=$(sudo ibdev2netdev -v | grep ${MT} | head -1 | awk '{print $1}')
fi
HCA_PORTS=$(sudo ibdev2netdev -v | grep ${MT} | wc -l)
FABRIC_TYPE=$(ibstat $HCA 1 | grep layer | cut -d' ' -f3)

# ConnectX-3 
if [ ${MT} == "MT4103" ]; then
    if [ $FABRIC_TYPE == "Ethernet" ]; then
        # The following line will be inserted to /etc/modprobe.d/mlx4_core.conf
        if [ ${HCA_PORTS} == 1 ]; then
            CONF_LINE="options mlx4_core port_type_array=2 num_vfs=${NUM_OF_VFS} probe_vf=${NUM_OF_VFS} enable_64b_cqe_eqe=0 log_num_mgm_entry_size=-1 enable_vfs_qos=1"
        fi
        if [ ${HCA_PORTS} == 2 ]; then
            CONF_LINE="options mlx4_core port_type_array=2,2 num_vfs=$HCA_BUS-${NUM_OF_VFS};0;0 probe_vf=$HCA_BUS-${NUM_OF_VFS};0;0 enable_64b_cqe_eqe=0 log_num_mgm_entry_size=-1 enable_vfs_qos=1"
        fi
        echo $CONF_LINE > /etc/modprobe.d/mlx4_core.conf
        echo "successfully configured modprobe file"
        exit 0
    fi
    if [ $FABRIC_TYPE == "InfiniBand" ]; then
        # The following line will be inserted to /etc/modprobe.d/mlx4_core.conf
        if [ ${HCA_PORTS} == 1 ]; then
            CONF_LINE="options mlx4_core port_type_array=1 num_vfs=${NUM_OF_VFS} probe_vf=0 enable_64b_cqe_eqe=0 log_num_mgm_entry_size=-1"
        fi
        if [ ${HCA_PORTS} == 2 ]; then
            CONF_LINE="options mlx4_core port_type_array=1,1 num_vfs=${NUM_OF_VFS} probe_vf=0 enable_64b_cqe_eqe=0 log_num_mgm_entry_size=-1"
        fi
        echo $CONF_LINE > /etc/modprobe.d/mlx4_core.conf
        # E_IPOIB_LOAD option in /etc/infiniband/openib.conf will be enabled
        sed -i  -e 's/E_IPOIB_LOAD=no/E_IPOIB_LOAD=yes/g' /etc/infiniband/openib.conf
        echo "successfully configured OFED rebooting host.."
        exit 0
    fi
    exit 1

elif [ ${MT} == "MT4115" ] || [ ${MT} == "MT4117" ]; then; then
	if [ $FABRIC_TYPE == "InfiniBand" ]; then
		sed -i  -e 's/E_IPOIB_LOAD=no/E_IPOIB_LOAD=yes/g' /etc/infiniband/openib.conf
	fi
    # Check crontab file existance
    if [ ! "$(crontab -l)" ]; then
        [ ! "$(crontab -l | { cat; echo ""; } | crontab - )"]
    fi
    # Check the Physical Port Number 
    ports_number=$(lspci | grep -c "\[ConnectX-4")
    if [ $ports_number == 1 ]; then
        crontab -l | { cat; echo "@reboot sleep 60 && echo ${NUM_OF_VFS} > /sys/class/infiniband/mlx5_0/device/sriov_numvfs"; } | crontab -
        exit 0
    fi
    if [ $ports_number == 2 ]; then
        crontab -l | { cat; echo "@reboot sleep 60 && echo ${NUM_OF_VFS} > /sys/class/infiniband/mlx5_0/device/sriov_numvfs"; } | crontab - 
        crontab -l | { cat; echo "@reboot sleep 60 && echo ${NUM_OF_VFS} > /sys/class/infiniband/mlx5_1/device/sriov_numvfs"; } | crontab - 
        exit 0
    fi
fi 
exit 1
