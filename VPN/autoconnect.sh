#!/bin/bash
ping -w 5 logrelay1.local > /dev/null 2>&1
if [[ $? -eq 0 ]]; then
    echo "Ping worked"
else
    echo "Ping failed"
    sleep 2
    /home/socadmin/forti-vpn.sh &
    systemctl restart nxlog
    systemctl status nxlog
fi
