echo "VPN Client To Site begin install..."
sleep 1.2
echo "Installing PPP Package"
apt install ppp expect -y
echo "Installing Forti SSL-VPN"
apt install ./VPN_Script/forticlient-sslvpn_4.4.2333-1_amd64.deb -y
echo "Installing Forti SSL-VPN"
