#!/usr/bin/env bash

# Install Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
apt-key fingerprint 0EBFCD88
add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
apt-get update

# Write Docker config
cat <<EOF > /etc/systemd/system/docker.service
[Service]
ExecStart=/usr/bin/dockerd --storage-driver=overlay2
LimitMEMLOCK=infinity
LimitNOFILE=infinity
LimitNPROC=infinity

[Install]
WantedBy=multi-user.target
EOF

apt-get install -y docker-ce=$DOCKER_VERSION*

# Restart Docker
systemctl daemon-reload
systemctl restart docker

# Add rancher user to docker group
usermod -aG docker $ADMIN_USERNAME
