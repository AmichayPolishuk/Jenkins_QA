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

CA=$(/usr/sbin/ibstat -l | head -1)
FABRIC_TYPE=$(/usr/sbin/ibstat $CA 1 | grep layer | cut -d' ' -f3)

# ConnectX-3 
if [ -n "$(lspci | grep ConnectX-3)" ]; then
    export HCA=${HCA:-"mlx4"}
# ConnectX-4
elif [ -n "$(lspci | grep ConnectX-4)" ]; then
    export HCA=${HCA:-"mlx5"}
fi 

mlx=`echo $HCA | sed s/mlx//g`
let mlx=mlx-1
export mlnx_dev=`lspci |grep Mell|grep "\-$mlx" |head -n1|awk '{print $1}' |  sed s/\.0\$//g`
export mlnx_port=`ibdev2netdev  | grep ${HCA}_0 | grep Up| grep ib| awk '{print $5}'|tail -n1`
echo $mlnx_dev
echo $mlnx_port

if [ $FABRIC_TYPE == "InfiniBand" ]; then
    export epioib_port=`ibdev2netdev  | grep ${HCA}_0 | grep Up| awk '{print $5}'|head -n1`
    echo $epioib_port
fi 


