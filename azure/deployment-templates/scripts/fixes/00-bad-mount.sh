#!/usr/bin/env bash

# Remove bad mount https://bugs.launchpad.net/ubuntu/+source/cloud-init/+bug/1603222
sed -i '/azure_resource/d' /etc/fstab
