#!/usr/bin/env bash
set -e

#
# https://github.com/systemd/systemd/issues/3374

cat <<EOF > /etc/systemd/network/99-default.link
[Link]
NamePolicy=kernel database onboard slot path
MACAddressPolicy=none
EOF

systemctl restart systemd-networkd
