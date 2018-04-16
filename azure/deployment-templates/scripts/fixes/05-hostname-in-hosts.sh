#!/usr/bin/env bash
set -e

echo "127.0.1.1 `hostname` `hostname -f`" >> /etc/hosts
