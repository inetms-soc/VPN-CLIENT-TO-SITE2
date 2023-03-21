#!/bin/bash

# Set the threshold for disk usage (in percentage)
THRESHOLD=90
# Get private IP address
PRIV_IP=$(hostname -I | awk '{print $1}')
# Get the current disk usage percentage
DISK_USAGE=$(df -h / | awk 'NR==2{print $5}' | cut -d'%' -f1)

# Check if the disk usage exceeds the threshold
if [ $DISK_USAGE -gt $THRESHOLD ]; then
    # If it does, send a notification to Line Alert
    MESSAGE="Disk usage on *$(hostname)* IP: *$PRIV_IP*  is currently at *$DISK_USAGE%*"
    echo $MESSAGE
    curl -X POST -H 'Authorization: Bearer mi6GxeQXqPxLATRvus3aj6WwBMq2x3lSA3KB1bAcsm0' -F "message=$MESSAGE" https://notify-api.line.me/api/notify
fi

