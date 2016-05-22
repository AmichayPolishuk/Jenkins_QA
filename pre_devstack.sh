#!/bin/bash

# Debug Session
if [ ${DEBUG_TRACE:-0} -gt 0 ]; then
    set -x
fi
# Error Handling
set -eu
set -o pipefail

# Install Packadges
sudo apt-get update
sudo apt-get install -y --force-yes sshpass
sudo apt-get install -y --force-yes openssh-server
sudo pip install setuptools==20.1.1

# Create Devstack User - stack

groupadd stack
useradd -g stack -s /bin/bash -d /opt/stack -m stack
echo "stack ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
echo -e 'stack\nstack\n' | sudo passwd stack