#!/bin/bash
# Debug Session
if [ ${DEBUG_TRACE:-0} -gt 0 ]; then
    set -x
fi

# Error Handling
set -eu
set -o pipefail

echo "========================================="
echo " Create&Edit local.conf for Compute Node "
echo "========================================="
cat > /opt/stack/devstack/local.conf << EOF
[[local|localrc]]
MULTI_HOST=1
ADMIN_PASSWORD=password
MYSQL_PASSWORD=password
RABBIT_PASSWORD=password
SERVICE_PASSWORD=password
HOST_IP=\$(host \$(hostname) | cut -d ' ' -f4)

# Branch's
NEUTRON_BRANCH=refs/changes/16/275616/5
NOVA_BRANCH=refs/changes/24/275624/14

# Stack
PIP_UPGRADE=True

# GIT
RECLONE=no

# Logging
LOGDIR=\${LOGDIR:-/opt/stack/logs}
LOGFILE=\$LOGDIR/stack.sh.log
LOG_COLOR=False
LOGDAYS=1

# Keystone
SERVICE_TOKEN=servicetoken

# Neutron
mlnx_port=`ip link show |grep -a2 vf |head -n1 |awk '{print \$2}' |tr -d :`
Q_PLUGIN=ml2
Q_AGENT=openvswitch
Q_ML2_PLUGIN_MECHANISM_DRIVERS=openvswitch
Q_USE_DEBUG_COMMAND=True
Q_USE_SECGROUP=True
ENABLE_TENANT_VLANS=True
Q_ML2_PLUGIN_TYPE_DRIVERS=vxlan,vlan
Q_ML2_TENANT_NETWORK_TYPE=vxlan,vlan
Q_TUNNEL_TYPES=vxlan
OVS_ENABLE_TUNNELING=True

# Interfaces
PHYSICAL_NETWORK=default
PHYSICAL_INTERFACE=\${mlnx_port}
OVS_PHYSICAL_BRIDGE=br-\${mlnx_port}
TUNNEL_ENDPOINT_IP=${tunnel_endpoint_ip}
TUNNEL_ENDPOINT_INTERFACE=\${OVS_PHYSICAL_BRIDGE}

#
SERVICE_HOST=${controller_ip_address}
MYSQL_HOST=${controller_ip_address}
RABBIT_HOST=${controller_ip_address}
Q_HOST=${controller_ip_address}
GLANCE_HOSTPORT=${controller_ip_address}:9292
NOVA_VNC_ENABLED=True
NOVNCPROXY_URL="http://${controller_ip_address}:6080/vnc_auto.html"
VNCSERVER_LISTEN=0.0.0.0
VNCSERVER_PROXYCLIENT_ADDRESS=\$VNCSERVER_LISTEN

# Services
ENABLED_SERVICES=n-cpu,q-agt,n-api-meta
USE_SCREEN=True

# Extra
mlnx_dev=`lspci |grep Mell|head -n1|awk '{print \$1}' |  sed s/\.0\$//g`
[[post-config|\$NOVA_CONF]]
[DEFAULT]
pci_passthrough_whitelist =[{"'"address"'":"'"*:'"\${mlnx_dev}"'.1"'","'"physical_network"'":"null"},{"'"address"'":"'"*:'"\${mlnx_dev}"'.2"'","'"physical_network"'":"null"},{"'"address"'":"'"*:'"\${mlnx_dev}"'.3"'","'"physical_network"'":"'"default"'"},{"'"address"'":"'"*:'"\${mlnx_dev}"'.4"'","'"physical_network"'":"'"default"'"}]
EOF
exit 0
