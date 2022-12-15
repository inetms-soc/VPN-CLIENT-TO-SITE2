#!/bin/sh

data="systemctl is-active --quiet nxlog"
dd="date"

if ($(eval  $data) > 0 )
then
echo "$($dd) nxlog service is running" >> /var/log/nxlog/nxlog.log
else
sleep 1
dd1="date"
echo "$($dd1) nxlog service not runing!!!" >> /var/log/nxlog/nxlog.log
sleep 1
pkill -9 nxlog
dd2="date"
echo "$($dd2) kill process nxlog" >> /var/log/nxlog/nxlog.log
sleep 1
systemctl restart nxlog
dd3="date"
echo "$($dd3) service running!!!" >> /var/log/nxlog/nxlog.log
fi
