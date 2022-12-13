#!/bin/bash
echo -e "Disconnect VPN Connection\n"
pkill ppp
echo -e "Remove PPP Interface\n"
apt remove --purge ppp -y
echo -e "Remove Forticlient VPN Package\n"
apt remove --purge forticlient-sslvpn -y
echo -e "Stop NXLog Service\n"
systemctl stop nxlog -y
echo -e "Remove NXLog-CE Package\n"
apt remove --purge nxlog-ce -y
echo -e "Validate Installed Packages"
apt list --installed | grep -i nxlog
apt list --installed | grep -i forti
apt list --installed | grep -i ppp
echo -e "Terminate Service Done...!\n"
