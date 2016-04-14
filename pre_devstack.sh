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
sudo pip install setuptools==20.1.1
sudo apt-get install python2.7-dev
sudo apt-get install -y --force-yes openssh-server
sudo apt-get install sshpass

# Create Devstack User - stack

groupadd stack
useradd -g stack -s /bin/bash -d /opt/stack -m stack
echo "stack ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
echo -e 'stack\nstack\n' | sudo passwd stack

# Open ssh to all servers 

su - stack
echo stack > password.txt
echo | ssh-keygen -P ''
host_list=(r-smg39 r-smg40 r-smg41)
for host_index in "${host_list[@]}"; do sshpass -f password.txt ssh-copy-id stack@$host_index; done