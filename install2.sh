#!/bin/bash

#Define System Variable
mkdir /home/socadmin
export soc_path="/home/socadmin"
cp -a ./VPN_Script/*.sh $soc_path

echo "VPN Client To Site begin install..."
sleep 1.2
#echo -e "Installing PPP Package\n"
read -p "Do you want to install ppp expect package y/n? " yn
if [ $yn == "Y" || $yn == "y"  ]
then
   echo -e "Installing PPP Package\n"
   apt install ppp expect -y
   echo "PPP Package was installed"
else
   read -p "Do you want to install ssl vpn package y/n? " yn
   if [ $yn == "Y" || $yn == "y"  ]
   then
      echo -e "Installing SSL VPN Package\n"
      apt install ./VPN_Script/forticlient-sslvpn_4.4.2333-1_amd64.deb -y
      echo -e "SSL VPN Package was installed\n"
   else
      read -p "Do you want to install nxlog -ce package y/n? " yn
      if [ $yn == "Y" || $yn == "y"  ]
      then
         echo -e "Installing SSL VPN Package\n"
         apt install ./NXLOG-Agents/NXLog_Ubuntu_Agents/nxlog-ce_3.1.2319_ubuntu18_amd64.deb -y
         echo -e "NXLOG-CE Package was installed\n"
         cp -a ./NXLog_Config/nxlog_server.conf /etc/nxlog/nxlog.conf
         echo "Copy NXLog Configuration Complete.....!"
      else
         echo "Nothing Change!!"     
fi
        

