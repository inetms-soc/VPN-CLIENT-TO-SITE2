#!/bin/bash
ping -w 5 logrelay2.local > /dev/null 2>&1
if [[ $? -eq 0 ]]; then
    echo "Ping worked"
else
    echo "Ping failed"
    sleep 2
    /home/socadmin/forti-vpn.sh &
    /home/socadmin/nxlog_monitor.sh
    systemctl restart nxlog
    systemctl status nxlog
fi
