#!/usr/bin/env bash
set -e

# Update Ubuntu
apt-get update

apt-get install -y software-properties-common

cat <<EOF > /etc/hosts
127.0.0.1 localhost

# The following lines are desirable for IPv6 capable hosts
::1 ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
ff02::3 ip6-allhosts
EOF


cat <<EOF > /etc/fstab
# CLOUD_IMG: This file was created/modified by the Cloud Image build process
LABEL=cloudimg-rootfs	/	 ext4	defaults,discard	0 0
EOF
