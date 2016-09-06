#!/usr/bin/env bash

export PATH=$PATH:/usr/sbin:/usr/bin

# OFED must be installed
if [ -z "$(ofed_info -s)" ]; then
    exit 1
fi

public_interface=$(sudo ip link show | grep -e "^3:" | awk '{print $2}' | cut -d':' -f1) 
export public_interface
echo $public_interface

CA=$(sudo ibstat -l | head -1)
FABRIC_TYPE=$(sudo ibstat $CA 1 | grep layer | cut -d' ' -f3)

# ConnectX-3
if [ -n "$(sudo lspci | grep ConnectX-3)" ]; then
    export HCA=${HCA:-"mlx4"}
# ConnectX-4
elif [ -n "$(sudo lspci | grep ConnectX-4)" ]; then
    export HCA=${HCA:-"mlx5"}
fi

mlx=`echo $HCA | sed s/mlx//g`
let mlx=mlx-1
export mlnx_dev=`sudo lspci |grep Mell|grep "\-$mlx" |head -n1|awk '{print $1}' |  sed s/\.0\$//g`
echo $mlnx_dev

if [ $FABRIC_TYPE == "Ethernet" ]; then
    export mlnx_port=`sudo ibdev2netdev  | grep Up| awk '{print $5}'|head -n1`
    echo $mlnx_port
fi

if [ $FABRIC_TYPE == "InfiniBand" ]; then
    export epioib_port=`sudo ibdev2netdev  | grep ${HCA}_0 | grep Up| awk '{print $5}'|head -n1`
    echo $epioib_port
    export mlnx_port=`sudo ibdev2netdev  | grep ${HCA}_0 | grep Up| grep ib| awk '{print $5}'|tail -n1`
    echo $mlnx_port
fi

