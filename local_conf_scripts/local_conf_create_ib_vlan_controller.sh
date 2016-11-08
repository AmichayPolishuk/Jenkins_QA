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
DOWNLOAD_DEFAULT_IMAGES=False
IMAGE_URLS="http://10.209.25.63/images/mellanox-rhel-7.2-OFED-latest.qcow2,"
IMAGE_URLS+="http://10.209.25.63/images/mellanox-ubuntu-xenial-OFED-latest.qcow2"
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
LOGDIR=/opt/stack/logs
LOGFILE=\$LOGDIR/stack.sh.log
LOG_COLOR=False
LOGDAYS=1

# Cinder
VOLUME_BACKING_FILE_SIZE=10000M

# Neutron
SERVICE_TOKEN=servicetoken
Q_PLUGIN=ml2
Q_ML2_PLUGIN_MECHANISM_DRIVERS=mlnx_sdn_assist,openvswitch,mlnx_infiniband
Q_AGENT=openvswitch
Q_USE_DEBUG_COMMAND=False
Q_USE_SECGROUP=True
ENABLE_TENANT_VLANS=True
ENABLE_TENANT_TUNNELS=False
Q_ML2_PLUGIN_TYPE_DRIVERS=flat,vlan
Q_ML2_TENANT_NETWORK_TYPE=vlan
TENANT_VLAN_RANGE=${vlan_pool_start}:${vlan_pool_end}
ML2_VLAN_RANGES=default:\$TENANT_VLAN_RANGE
NETWORK_API_EXTENSIONS=dhcp_agent_scheduler,external-net,ext-gw-mode,binding,quotas,agent,l3_agent_scheduler,provider,router,extraroute,security-group
ALLOW_NEUTRON_DB_MIGRATIONS=true
Q_ML2_PLUGIN_FLAT_TYPE_OPTIONS=public

# Networks
IP_VERSION=4
FIXED_RANGE="192.168.1.0/24"
NETWORK_GATEWAY=192.168.1.1
PROVIDER_SUBNET_NAME=private_network
PROVIDER_NETWORK_TYPE=vlan
Q_USE_PROVIDERNET_FOR_PUBLIC=True
PUBLIC_NETWORK_GATEWAY=${public_gateway}
FLOATING_RANGE=${floating_range}
Q_FLOATING_ALLOCATION_POOL=start=${floating_allocation_pool_start},end=${floating_allocation_pool_end}

# Interfaces
PHYSICAL_NETWORK=default
PHYSICAL_INTERFACE=${mlnx_interface}
OVS_PHYSICAL_BRIDGE=br-${mlnx_interface}
PUBLIC_PHYSICAL_NETWORK=public
PUBLIC_INTERFACE=${public_interface}
PUBLIC_BRIDGE=br-ex
OVS_BRIDGE_MAPPINGS=default:br-${mlnx_interface},public:br-ex

# Services
disable_service h-eng h-api h-api-cfn h-api-cw n-net n-cpu
enable_service neutron q-svc q-agt q-dhcp q-l3 q-meta n-novnc n-xvnc n-cauth horizon tempest mlnx_dnsmasq

# Plugins
enable_plugin neutron_ml2_mlnx git://github.com/openstack/networking-mlnx ${OS_BRANCH}

# Extra
[[post-config|\$NOVA_CONF]]
[DEFAULT]
scheduler_available_filters=nova.scheduler.filters.all_filters
scheduler_default_filters = RetryFilter, AvailabilityZoneFilter, RamFilter, ComputeFilter, ComputeCapabilitiesFilter, ImagePropertiesFilter, PciPassthroughFilter

[[post-config|/etc/neutron/plugins/ml2/ml2_conf.ini]]
[sdn]
url = http://10.209.25.203/neo
username = admin
password = 123456
[ml2_sriov]
supported_pci_vendor_devs = 15b3:1004,15b3:1014,15b3:1016

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

[[post-extra|\$TEMPEST_CONFIG]]
[network]
port_vnic_type=direct

[[post-config|/etc/neutron/plugins/ml2/ml2_conf.ini]]
[ovs]
of_interface=ovs-ofctl 
EOF
exit 0
