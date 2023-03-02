#!/bin/bash

# Detect OS type and version
if [ -f /etc/os-release ]; then
    # For modern Linux distributions that use systemd
    . /etc/os-release
    OS=$NAME
    VER=$VERSION_ID
elif [ -f /etc/lsb-release ]; then
    # For Ubuntu and Debian based distributions
    . /etc/lsb-release
    OS=$DISTRIB_ID
    VER=$DISTRIB_RELEASE
else
    # For other Linux distributions
    OS=$(uname -s)
    VER=$(uname -r)
fi

# Get private IP address
PRIV_IP=$(hostname -I | awk '{print $1}')

# Get public IP address
PUB_IP=$(curl -s https://checkip.amazonaws.com)

# Get hostname
HOSTNAME=$(hostname)

echo "Operating System: $OS $VER"
echo "Private IP address: $PRIV_IP"
echo "Public IP address: $PUB_IP"
echo "Hostname: $HOSTNAME"
