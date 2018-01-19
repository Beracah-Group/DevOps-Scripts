#!/bin/bash

# Update Ubuntu

apt-get update

# Remove bad mount https://bugs.launchpad.net/ubuntu/+source/cloud-init/+bug/1603222

sed -i '/azure_resource/d' $fstab

# Setup ZFS

apt-get install -y software-properties-common zfs python-pip

zpool create -f zpool-docker /dev/sdc

zfs create -o mountpoint=/var/lib/docker zpool-docker/docker

# Install Docker 17+

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

apt-key fingerprint 0EBFCD88

add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

apt-get update

apt-get install -y docker-ce=$DOCKER_VERSION~ce-0~ubuntu

# Write Docker config

cat <<EOF > /etc/systemd/system/docker.service
[Service]
ExecStart=/usr/bin/dockerd --storage-driver=zfs

[Install]
WantedBy=multi-user.target
EOF

# Restart Docker

systemctl daemon-reload

systemctl restart docker

# Add rancher user to docker group

usermod -aG docker $ADMIN_USERNAME

# Run Rancher HA script

bash rancherha.sh