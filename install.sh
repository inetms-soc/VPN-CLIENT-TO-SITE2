#!/bin/bash

#Define System Variable
mkdir /home/socadmin
export soc_path="/home/socadmin"
cp -a ./VPN_Script/*.sh $soc_path

echo "VPN Client To Site begin install..."
sleep 1.2
#echo -e "Installing PPP Package\n"
while true; do
    read -p "Do you want to install ppp expect package y/n? " yn
    case $yn in
        [Yy]* )
        echo -e "Installing PPP Package\n"
        apt install ppp expect -y
        echo "PPP Package was installed"
        break;;
        # if type no = exit
        [Nn]* )
        break;;
        * )
        echo "Please answer yes or no.";;
    esac
done


while true; do
    read -p "Do you want to install SSL VPN package y/n? " yn
    case $yn in
        [Yy]* )
        echo -e "Installing Forti SSL-VPN\n"
        apt install ./VPN_Script/forticlient-sslvpn_4.4.2333-1_amd64.deb -y
        echo "Install Forti SSL-VPN Complete.....!"
        break;;
        # if type no = exit
        [Nn]* )
        break;;
        * )
        echo "Please answer yes or no.";;
    esac
done


while true; do
    read -p "Do you want to install NXLog-CE package y/n? " yn
    case $yn in
        [Yy]* )
        echo -e "Installing NXLog-CE Package\n"
        apt install ./NXLOG-Agents/NXLog_Ubuntu_Agents/nxlog-ce_3.1.2319_ubuntu18_amd64.deb -y
        echo "Install NXLog-CE Complete.....!"
        cp -a ./NXLog_Config/nxlog_server.conf /etc/nxlog/nxlog.conf
        echo "Copy NXLog Configuration Complete.....!"
        break;;
        # if type no = exit
        [Nn]* )
        break;;
        * )
        echo "Please answer yes or no.";;
    esac
done

echo -e "Validate Installed Packages...\n"
apt list --installed | grep -i nxlog
apt list --installed | grep -i forti
apt list --installed | grep -i ppp

echo "Installation Complete"
