#!/bin/bash

# Debug Session
if [ ${DEBUG_TRACE:-0} -gt 0 ]; then
    set -x
fi
# Error Handling
set -eu
set -o pipefail

# Open ssh to all servers 
local_setup_list = ${SETUP_LIST} 
echo stack > password.txt
echo | ssh-keygen -P ''
for host_index in "${local_setup_list[@]}"; do sshpass -f password.txt ssh-copy-id stack@$host_index; done