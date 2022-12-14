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
        echo "Installing PPP Package....."
        apt install ppp expect -y
        echo -e "PPP Expect was installed\n"
        V1="PPP Package"
        break;;
        # if type no = exit
        [Nn]* )
        V1=""
        break;;
        * )
        echo "Please answer yes or no.";;
    esac
done


while true; do
    read -p "Do you want to install SSL VPN package y/n? " yn
    case $yn in
        [Yy]* )
        echo "Installing Forti SSL-VPN Package....."
        apt install ./VPN_Script/forticlient-sslvpn_4.4.2333-1_amd64.deb -y
        echo -e "Forti SSL-VPN was installed\n"
        V2="Forti SSL-VPN Package"
        break;;
        # if type no = exit
        [Nn]* )
        V2=""
        break;;
        * )
        echo "Please answer yes or no.";;
    esac
done


while true; do
    read -p "Do you want to install NXLog-CE package y/n? " yn
    case $yn in
        [Yy]* )
        echo "Installing NXLog-CE Package"
        apt install ./NXLOG-Agents/NXLog_Ubuntu_Agents/nxlog-ce_3.1.2319_ubuntu18_amd64.deb -y
        echo "NXLog-CE was installed"
        cp -a ./NXLog_Config/nxlog_server.conf /etc/nxlog/nxlog.conf
        echo -e "Copy NXLog Configuration Done.....!\n"
        V3="NXLog-CE Package"
        break;;
        # if type no = exit
        [Nn]* )
        V3=""
        break;;
        * )
        echo "Please answer yes or no.";;
    esac
done

echo -e "Validate Installed Packages..."
apt list --installed | grep -i nxlog
apt list --installed | grep -i forti
apt list --installed | grep -i ppp

echo -e "Installation following package complete\n$V1\n$V2\n$V3"
