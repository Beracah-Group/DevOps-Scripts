#!/usr/bin/env bash
set -e

echo "*  soft  nofile 1000000" >> /etc/security/limits.conf
echo "*  hard  nofile 1000000" >> /etc/security/limits.conf
