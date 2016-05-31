#!/bin/bash

# Debug Session
if [ ${DEBUG_TRACE:-0} -gt 0 ]; then
    set -x
fi

# Error Handling
set -eu
set -o pipefail

# Install lldpd on host

if [ $OS == "Ubuntu_14.04" ] || [ $OS == "Ubuntu_16.04" ]; then
	sudo sh -c "echo 'deb http://download.opensuse.org/repositories/home:/vbernat/x${OS}/ /' >> /etc/apt/sources.list.d/lldpd.list"
	sudo apt-get -y --force-yes install lldpd
	# Update hostname using lldpdcli
	lldpcli configure system hostname $HOSTNAME
	lldpcli update
fi

if [ $OS == "Fedora_23" ]; then
	cd /etc/yum.repos.d/
	wget http://download.opensuse.org/repositories/home:vbernat/Fedora_23/home:vbernat.repo
	yum install -y lldpd
	systemctl restart lldpd.service
	lldpcli configure system hostname $HOSTNAME
	lldpcli update
fi
