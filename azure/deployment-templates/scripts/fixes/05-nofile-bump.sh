#!/usr/bin/env bash

echo "*  soft  nofile 1000000" >> /etc/security/limits.conf
echo "*  hard  nofile 1000000" >> /etc/security/limits.conf
