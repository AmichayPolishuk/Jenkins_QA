#!/bin/bash

# Debug Session
if [ ${DEBUG_TRACE:-0} -gt 0 ]; then
    set -x
fi
# Error Handling
set -eu
set -o pipefail

# Open ssh to all servers 

su - stack
echo stack > password.txt
echo | ssh-keygen -P ''
for host_index in "${SETUP_LIST[@]}"; do sshpass -f password.txt ssh-copy-id stack@$host_index; done