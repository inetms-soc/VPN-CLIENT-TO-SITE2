echo "VPN Client To Site begin install..."
sleep 1
echo "Installing PPP Package"
apt install ppp expect
echo "Installing Forti SSL-VPN"
apt install ./VPN-CLIENT-TO-SITE/VPN_Script/forticlient-sslvpn_4.4.2333-1_amd64.deb
#echo "Installing Forti SSL-VPN"
