#!/usr/bin/env bash
export PATH=$PATH:/usr/sbin:/usr/bin
TMP_DEV=tmp_ibdev2netdev

# Force Nic
FORCE_NIC=${FORCE_NIC:-""}

# OFED must be installed
if [ -z "$(ofed_info -s)" ]; then
    exit 1
fi

sudo ibdev2netdev -v > ${TMP_DEV}

MT=""
if [ "${FORCE_NIC}"" != "" ]; then
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

if [ "${MT}"" == "" ]; then
    MT=$(sudo cat $TMP_DEV | head -1 | awk '{print $3}' | cut -d'(' -f2)
fi

HCA=$(sudo cat $TMP_DEV | grep ${MT} | head -1 | awk '{print $2}')
HCA_BUS=$(sudo cat $TMP_DEV | grep ${MT} | head -1 | awk '{print $1}' | cut -d':' -f2,3 | cut -d'.' -f1)
HCA_PORTS=$(sudo cat $TMP_DEV | grep ${MT} | wc -l)
HCA_PORT_NAME=$(sudo cat $TMP_DEV | grep ${MT} | head -1 | cut -d'>' -f2 | cut -d' ' -f2)
FABRIC_TYPE=$(ibstat $HCA 1 | grep layer | cut -d' ' -f3)
export mlnx_dev=${HCA_BUS}
echo $mlnx_dev

if [ "$FABRIC_TYPE" == "Ethernet" ]; then
    export mlnx_port=${HCA_PORT_NAME}
    sudo ip link set dev $mlnx_port up
    echo $mlnx_port
fi

if [ "$FABRIC_TYPE" == "InfiniBand" ]; then
    export epioib_port=${HCA_PORT_NAME}
    echo $epioib_port
    sudo ip link set dev $epioib_port up
    export mlnx_port=$(sudo cat $TMP_DEV | grep ${MT} | head -2 | tail -1 | awk '{print $17}')
    echo $mlnx_port
fi

