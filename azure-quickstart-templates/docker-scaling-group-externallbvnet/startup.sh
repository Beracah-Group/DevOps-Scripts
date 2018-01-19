# Update Ubuntu

apt-get update

# Remove bad mount https://bugs.launchpad.net/ubuntu/+source/cloud-init/+bug/1603222

sed -i '/azure_resource/d' $fstab

# Setup ZFS

apt-get install -y software-properties-common zfs

zpool create -f zpool-docker /dev/sdc

zfs create -o mountpoint=/var/lib/docker zpool-docker/docker

# Install Docker

apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D

apt-add-repository 'deb https://apt.dockerproject.org/repo ubuntu-xenial main'

apt-get update

apt-cache policy docker-engine

apt-get install -y docker-engine=$DOCKER_VERSION-0~ubuntu-xenial

# Write Docker config

cat <<EOF > /etc/systemd/system/docker.service
[Service]
ExecStart=/usr/bin/docker daemon --storage-driver=zfs

[Install]
WantedBy=multi-user.target
EOF

# Restart Docker

systemctl daemon-reload

systemctl restart docker

# Add Linux user to docker group

usermod -aG docker $LINUX_USER