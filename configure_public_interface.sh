#!/bin/bash
# Debug Session
if [ ${DEBUG_TRACE:-0} -gt 0 ]; then
    set -x
fi

# Error Handling
set -eu
set -o pipefail

echo ${public_interface_ip}

#sudo bash -c 'cat << EOF > /etc/sysconfig/network-scripts/ifcfg-br-ex
#DEVICE=br-ex
#BOOTPROTO=none
#ONBOOT=yes
#NETWORK=10.209.86.0
#PREFIX=24
#IPADDR='${public_interface_ip}'
#EOF'
sudo ifconfig $public_interface $public_interface_ip/$(echo $floating_range | cut -d'/' -f2)
