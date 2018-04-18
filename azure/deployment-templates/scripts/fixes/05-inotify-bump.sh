#!/usr/bin/env bash
set -e

echo "fs.inotify.max_user_instances=8192" >> /etc/sysctl.conf
sysctl -p
