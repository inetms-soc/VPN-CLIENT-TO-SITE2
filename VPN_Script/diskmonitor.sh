#!/bin/bash

# Set the threshold for disk usage (in percentage)
THRESHOLD=85
# Get private IP address
PRIV_IP=$(hostname -I | awk '{print $1}')
# Get the current disk usage percentage
DISK_USAGE=$(df -h / | awk 'NR==2{print $5}' | cut -d'%' -f1)
#lastest add token = THAISINTO
# Check if the disk usage exceeds the threshold
if [ $DISK_USAGE -gt $THRESHOLD ]; then
    # If it does, send a notification to Line Alert
    MESSAGE="Disk usage on path / *$(hostname)* IP: *$PRIV_IP*  is currently at *$DISK_USAGE%*"
    echo $MESSAGE
    curl -X POST -H 'Authorization: Bearer jczAjO9hokC0ECYFRz0riM1WFDtsx3vhJMHkUIsRTem' -F "message=$MESSAGE" https://notify-api.line.me/api/notify
fi

