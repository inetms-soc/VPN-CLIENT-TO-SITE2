echo "VPN Client To Site begin install..."
sleep 1.2
echo "Installing PPP Package"
apt install ppp expect -y
echo "Installing Forti SSL-VPN"
apt install ./forticlient-sslvpn_4.4.2333-1_amd64.deb -y
echo "Install Forti SSL-VPN Done...!"
