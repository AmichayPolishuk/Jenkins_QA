#!/bin/bash

HCA=$(ibstat -l | head -1)
FABRIC_TYPE=$(ibstat $HCA 1 | grep layer | cut -d' ' -f3)

# ConnectX-3 
if [ $HCA == "mlx4_0" ]; then

    if [ $FABRIC_TYPE == "Ethernet" ]; then
        HCA_BUS=$(lspci | grep nox | head -1 | cut -d':' -f1)
        lspci | grep nox
        # The following line will be inserted to /etc/modprobe.d/mlx4_core.conf
        CONF_LINE="options mlx4_core port_type_array=2,2 num_vfs=0000:$HCA_BUS:00.0-4;0;0 probe_vf=0000:$HCA_BUS:00.0-4;0;0 enable_64b_cqe_eqe=0 log_num_mgm_entry_size=-1 enable_vfs_qos=1"
        echo $CONF_LINE > /etc/modprobe.d/mlx4_core.conf
        echo "successfully configured OFED rebooting host.."
        reboot
    fi

    if [ $FABRIC_TYPE == "InfiniBand" ]; then
        # The following line will be inserted to /etc/modprobe.d/mlx4_core.conf
        CONF_LINE="options mlx4_core port_type_array=1,1 num_vfs=4 probe_vf=0 enable_64b_cqe_eqe=0 log_num_mgm_entry_size=-1"
        echo $CONF_LINE > /etc/modprobe.d/mlx4_core.conf
        # E_IPOIB_LOAD option in /etc/infiniband/openib.conf will be enabled
        sed -i  -e 's/E_IPOIB_LOAD=no/E_IPOIB_LOAD=yes/g' /etc/infiniband/openib.conf
        echo "successfully configured OFED rebooting host.."
        reboot
    fi
# ConnectX-4 
else
 
    echo "echo 4 > /sys/class/infiniband/mlx5_0/device/sriov_numvfs" >> /etc/rc.local
    # Activate vf's after reboot
    chmod +x /etc/rc.local
    reboot

fi 
