#!/bin/bash
# Debug Session
if [ ${DEBUG_TRACE:-0} -gt 0 ]; then
    set -x
fi

# Error Handling
set -eu
set -o pipefail

cat > /opt/stack/devstack/local.conf <<EOF
[[local|localrc]]
MULTI_HOST=1
ADMIN_PASSWORD=password
MYSQL_PASSWORD=password
RABBIT_PASSWORD=password
SERVICE_PASSWORD=password
HOST_IP=\$(host \$(hostname) | cut -d ' ' -f4)

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
Q_PLUGIN=ml2
Q_AGENT=openvswitch
Q_ML2_PLUGIN_MECHANISM_DRIVERS=openvswitch,mlnx
Q_USE_DEBUG_COMMAND=True
Q_USE_SECGROUP=True
ENABLE_TENANT_VLANS=True
Q_ML2_PLUGIN_TYPE_DRIVERS=vlan
Q_ML2_TENANT_NETWORK_TYPE=vlan
ENABLE_TENANT_TUNNELS=False

# Interfaces
PHYSICAL_NETWORK=default
PHYSICAL_INTERFACE=${mlnx_eipoib_interface}
OVS_PHYSICAL_BRIDGE=br-${mlnx_eipoib_interface}

# IB - eswitchd mapping
PHYSICAL_INTERFACE_MAPPINGS=default:${mlnx_interface}

# Controller connection
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
ENABLED_SERVICES=n-cpu,q-agt,n-api-meta,mlnx-agt,eswitchd
USE_SCREEN=True

# Plugins
enable_plugin neutron_ml2_mlnx git://github.com/openstack/networking-mlnx ${OS_BRANCH}

# Extra
[[post-config|\$NOVA_CONF]]
[DEFAULT]
pci_passthrough_whitelist ={"'"address"'":"'"*:${mlnx_dev}:*.*"'","'"physical_network"'":"'"default"'"}
[[post-config|/etc/neutron/plugins/ml2/ml2_conf.ini]]
[ovs]
of_interface=ovs-ofctl
EOF
exit 0
