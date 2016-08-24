[[local|localrc]]
MULTI_HOST=1
ADMIN_PASSWORD=password
MYSQL_PASSWORD=password
RABBIT_PASSWORD=password
SERVICE_PASSWORD=password
HOST_IP=$(host $(hostname) | cut -d ' ' -f4)
NEUTRON_BRANCH=refs/changes/16/275616/5
NOVA_BRANCH=refs/changes/24/275624/14
# Logging
LOGDIR=${LOGDIR:-/opt/stack/logs}
LOGFILE=$LOGDIR/stack.sh.log
LOG_COLOR=False
RECLONE=yes
# Keystone
SERVICE_TOKEN=servicetoken

# Neutron
mlnx_port=`ip link show |grep -a2 vf |head -n1 |awk '{print $2}' |tr -d :`
Q_PLUGIN=ml2
Q_AGENT=openvswitch
Q_ML2_PLUGIN_MECHANISM_DRIVERS=openvswitch
Q_USE_DEBUG_COMMAND=True
Q_USE_SECGROUP=True
ENABLE_TENANT_VLANS=True
Q_ML2_PLUGIN_TYPE_DRIVERS=vxlan,vlan
Q_ML2_TENANT_NETWORK_TYPE=vxlan,vlan
PHYSICAL_NETWORK=default
PHYSICAL_INTERFACE=${mlnx_port}
OVS_PHYSICAL_BRIDGE=br-${mlnx_port}
OVS_ENABLE_TUNNELING=True
TUNNEL_ENDPOINT_IP=10.10.10.3

#
SERVICE_HOST=10.209.24.134
MYSQL_HOST=10.209.24.134
RABBIT_HOST=10.209.24.134
Q_HOST=10.209.24.134
GLANCE_HOSTPORT=10.209.24.134:9292
NOVA_VNC_ENABLED=True
NOVNCPROXY_URL="http://10.209.24.134:6080/vnc_auto.html"
VNCSERVER_LISTEN=0.0.0.0
VNCSERVER_PROXYCLIENT_ADDRESS=$VNCSERVER_LISTEN

# Services
ENABLED_SERVICES=n-cpu,q-agt,n-api-meta
USE_SCREEN=True

#
mlnx_dev=`lspci |grep Mell|head -n1|awk '{print $1}' |  sed s/\.0$//g`
[[post-config|$NOVA_CONF]]
[DEFAULT]
pci_passthrough_whitelist =[{"'"address"'":"'"*:'"${mlnx_dev}"'.1"'","'"physical_network"'":"null"},{"'"address"'":"'"*:'"${mlnx_dev}"'.2"'","'"physical_network"'":"null"},{"'"address"'":"'"*:'"${mlnx_dev}"'.3"'","'"physical_network"'":"'"default"'"},{"'"address"'":"'"*:'"${mlnx_dev}"'.4"'","'"physical_network"'":"'"default"'"}]

