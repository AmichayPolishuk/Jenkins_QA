#!/bin/bash
# Debug Session
if [ ${DEBUG_TRACE:-0} -gt 0 ]; then
    set -x
fi

# Error Handling
set -eu
set -o pipefail

echo "==========================================================="
echo " Create&Edit local.conf for Controller-Network-Cinder Node "
echo "==========================================================="
cat > /opt/stack/devstack/local.conf << EOF
[[local|localrc]]
DOWNLOAD_DEFAULT_IMAGES=False
IMAGE_URLS="http://10.209.24.107/images/mellanox-ubuntu-xenial-OFED3.3-1.5.0.0.qcow2,"
IMAGE_URLS+="http://10.209.24.107/images/mellanox-rhel7.2-OFED3.3-1.5.0.0.qcow2"
MULTI_HOST=1
ADMIN_PASSWORD=password
MYSQL_PASSWORD=password
RABBIT_PASSWORD=password
SERVICE_PASSWORD=password
HOST_IP=\$(host \$(hostname) | cut -d ' ' -f4)

# Logging
LOGDIR=/opt/stack/logs
LOGFILE=$LOGDIR/stack.sh.log
LOG_COLOR=False
LOGDAYS=1

# GIT
RECLONE=no
NEUTRON_BRANCH=refs/changes/16/275616/5
NOVA_BRANCH=refs/changes/24/275624/14

# Cinder
VOLUME_BACKING_FILE_SIZE=10000M

# Neutron
SERVICE_TOKEN=servicetoken
Q_PLUGIN=ml2        
Q_ML2_PLUGIN_MECHANISM_DRIVERS=openvswitch
Q_AGENT=openvswitch
Q_USE_DEBUG_COMMAND=False
Q_USE_SECGROUP=True
Q_ML2_PLUGIN_TYPE_DRIVERS=flat,vxlan
Q_ML2_TENANT_NETWORK_TYPE=vxlan
NETWORK_API_EXTENSIONS=dhcp_agent_scheduler,external-net,ext-gw-mode,binding,quotas,agent,l3_agent_scheduler,provider,router,extraroute,security-group
ALLOW_NEUTRON_DB_MIGRATIONS=true
Q_ML2_PLUGIN_FLAT_TYPE_OPTIONS=public

# Networks
IP_VERSION=4
FIXED_RANGE="192.168.1.0/24"
NETWORK_GATEWAY=192.168.1.1
PROVIDER_SUBNET_NAME=private_network
PROVIDER_NETWORK_TYPE=vxlan
Q_USE_PROVIDERNET_FOR_PUBLIC=True
PUBLIC_NETWORK_GATEWAY=${public_gateway}
FLOATING_RANGE=${floating_range}
Q_FLOATING_ALLOCATION_POOL=start=${floating_allocation_pool_start},end=${floating_allocation_pool_end}

# Interfaces
mlnx_port=`ip link show |grep -a2 vf |head -n1 |awk '{print \$2}' |tr -d :`
public_interface=`ip link show | grep -e "^3:" | awk '{print \$2}' | cut -d':' -f1`
PHYSICAL_INTERFACE=\${mlnx_port}
PUBLIC_INTERFACE=\${public_interface}
PUBLIC_BRIDGE=br-ex
PUBLIC_PHYSICAL_NETWORK=public
OVS_BRIDGE_MAPPINGS=public:br-ex
TUNNEL_ENDPOINT_IP=${tunnel_endpoint_ip}
TUNNEL_ENDPOINT_INTERFACE=\${PHYSICAL_INTERFACE}

# Services
disable_service h-eng h-api h-api-cfn h-api-cw n-net n-cpu
enable_service neutron q-svc q-agt q-dhcp q-l3 q-meta n-novnc n-xvnc n-cauth horizon
enable_service tempest
USE_SCREEN=True

# Extra
[[post-config|\$NOVA_CONF]]
[DEFAULT]
scheduler_available_filters=nova.scheduler.filters.all_filters
scheduler_default_filters = RetryFilter, AvailabilityZoneFilter, RamFilter, ComputeFilter, ComputeCapabilitiesFilter, ImagePropertiesFilter, PciPassthroughFilter

[[post-config|/etc/cinder/cinder.conf]]
[DEFAULT]
enabled_backends = lvmdriver-1, backend1

[backend1]
iscsi_ip_address=1.1.1.1
iscsi_helper=tgtadm
iscsi_protocol = iser
volume_driver = cinder.volume.drivers.lvm.LVMVolumeDriver
volume_backend_name = backend1
volume_group = stack-volumes-lvmdriver-1

[[post-extra|$TEMPEST_CONFIG]]
[network]
port_vnic_type=direct
EOF
exit 0
