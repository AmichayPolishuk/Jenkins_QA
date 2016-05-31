#!/bin/bash

# Debug Session
if [ ${DEBUG_TRACE:-0} -gt 0 ]; then
    set -x
fi
# Error Handling
set -eu
set -o pipefail

# Create Devstack User - stack

groupadd stack
useradd -g stack -s /bin/bash -d /opt/stack -m stack
echo "stack ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
echo -e 'stack\nstack\n' | sudo passwd stack