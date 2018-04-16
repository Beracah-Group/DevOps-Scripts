#!/usr/bin/env bash
set -e

DEVICE=/dev/sdc

mkfs.xfs ${DEVICE} -n ftype=1
echo "/dev/sdc /var/lib/docker xfs defaults,noatime 0 2" >> /etc/fstab

mkdir -p /var/lib/docker

mount -a
