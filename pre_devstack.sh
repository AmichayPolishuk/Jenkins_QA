#!/bin/bash

# Install Packadges 

sudo apt-get update
sudo apt-get install python-pip -y
sudo apt-get install pip -y
sudo pip install setuptools==20.1.1
sudo apt-get install python2.7-dev
sudo apt-get -y install openssh-server

# Create Devstack User - stack

groupadd stack
useradd -g stack -s /bin/bash -d /opt/stack -m stack
echo "stack ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
echo -e 'stack\nstack\n' | sudo passwd stack

# Open ssh to all servers 

host_list=("r-smg39" "r-smg40" "r-smg41")
su - stack
for host_index in "${host_list}"
do
    echo -e 'n\n\n\' | sudo ssh-keygen -t rsa
    ssh-copy-id stack@"$host_index"    
done 

