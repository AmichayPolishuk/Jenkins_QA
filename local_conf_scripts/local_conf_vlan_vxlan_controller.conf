[[local|localrc]]
DOWNLOAD_DEFAULT_IMAGES=False
IMAGE_URLS="http://10.209.24.107/images/mellanox-ubuntu-xenial-OFED3.3-1.5.0.0.qcow2,"
IMAGE_URLS+="http://10.209.24.107/images/mellanox-rhel7.2-OFED3.3-1.5.0.0.qcow2"
MULTI_HOST=1
ADMIN_PASSWORD=password
MYSQL_PASSWORD=password
RABBIT_PASSWORD=password
SERVICE_PASSWORD=password
HOST_IP=$(host $(hostname) | cut -d ' ' -f4)
NEUTRON_BRANCH=refs/changes/16/275616/5
NOVA_BRANCH=refs/changes/24/275624/14
# Logging
LOGDIR=/opt/stack/logs
LOGFILE=$LOGDIR/stack.sh.log
LOG_COLOR=False
RECLONE=yes
LOGDAYS=1
# Cinder
VOLUME_BACKING_FILE_SIZE=10000M
# Neutron
mlnx_port=`ip link show |grep -a2 vf |head -n1 |awk '{print $2}' |tr -d :`
SERVICE_TOKEN=servicetoken
Q_PLUGIN=ml2        
Q_ML2_PLUGIN_MECHANISM_DRIVERS=openvswitch
Q_AGENT=openvswitch
Q_USE_DEBUG_COMMAND=False
Q_USE_SECGROUP=True
ENABLE_TENANT_VLANS=True
TENANT_VLAN_RANGE=51:60
Q_ML2_PLUGIN_TYPE_DRIVERS=flat,vxlan,vlan
Q_ML2_TENANT_NETWORK_TYPE=vxlan,vlan
Q_TUNNEL_TYPES=vxlan
PHYSICAL_NETWORK=default
NETWORK_API_EXTENSIONS=dhcp_agent_scheduler,external-net,ext-gw-mode,binding,quotas,agent,l3_agent_scheduler,provider,router,extraroute,security-group
OVS_PHYSICAL_BRIDGE=br-${mlnx_port}
ALLOW_NEUTRON_DB_MIGRATIONS=true
IP_VERSION=4
FIXED_RANGE="192.168.1.0/24"
NETWORK_GATEWAY=192.168.1.1
PROVIDER_SUBNET_NAME=private_network
PROVIDER_NETWORK_TYPE=vxlan
PUBLIC_NETWORK_GATEWAY=10.209.86.1
FLOATING_RANGE=10.209.86.0/24
Q_FLOATING_ALLOCATION_POOL=start=10.209.86.26,end=10.209.86.35
Q_USE_PROVIDERNET_FOR_PUBLIC=True
PUBLIC_PHYSICAL_NETWORK=public
Q_ML2_PLUGIN_FLAT_TYPE_OPTIONS=public
PUBLIC_INTERFACE=em2
PUBLIC_BRIDGE=br-ex
OVS_BRIDGE_MAPPINGS=default:br-${mlnx_port},public:br-ex
ML2_VLAN_RANGES=default:$TENANT_VLAN_RANGE
PHYSICAL_INTERFACE=${mlnx_port}
OVS_ENABLE_TUNNELING=True
TUNNEL_ENDPOINT_IP=10.10.10.1

disable_service h-eng h-api h-api-cfn h-api-cw n-net n-cpu
enable_service neutron q-svc q-agt q-dhcp q-l3 q-meta n-novnc n-xvnc n-cauth horizon
enable_service tempest
USE_SCREEN=True

[[post-config|$NOVA_CONF]]
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
