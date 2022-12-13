echo "Disconnect VPN Connection"
pkill ppp
echo "Remove PPP Interface"
apt remove --purge ppp
echo "Remove Forticlient VPN Package"
apt remove --purge forticlientsslvpn
echo "Stop NXLog Service"
systemctl stop nxlog
echo "Remove NXLog-CE Package"
apt remove --purge nxlog-ce
echo "Terminate Service Done...!"