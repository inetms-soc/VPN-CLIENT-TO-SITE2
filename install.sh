#!/bin/bash
#Define System Variable
mkdir /home/socadmin
unset soc_path
export soc_path="/home/socadmin"

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
        echo "Forti SSL-VPN was installed"
        cp -a ./VPN_Script/*.sh $soc_path
        echo -e "Copy vpn configuration to this path: $soc_path complete!\n"
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
        while true; do
            read -p "Which type of OS 1.Ubuntu, 2.CentOS ? " OS
            case $OS in
                [1] )
                echo "You Select Ubuntu OS"
                while true; do
                    echo -e "Which type of OS \n   1.Ubuntu16.04\n   2.Ubuntu18.04\n   3.Ubuntu20.04\n   4.Ubuntu22.04"
                    read -p "Select: " VERSION
                    case $VERSION in
                        [1] )
                        echo "You Select 1.Ubuntu16.04"
                        sleep 1
                        apt install ./NXLOG-Agents/NXLog_Ubuntu_Agents/nxlog-ce_3.1.2319_ubuntu16_amd64.deb -y
                        echo "nxlog-ce_3.1.2319_ubuntu16 was installed"
                        sleep 1
                        break;;
                        [2] )
                        echo "You Select 2.Ubuntu18.04"
                        apt install ./NXLOG-Agents/NXLog_Ubuntu_Agents/nxlog-ce_3.1.2319_ubuntu18_amd64.deb -y
                        echo "nxlog-ce_3.1.2319_ubuntu18 was installed"
                        sleep 1
                        break;;
                        [3] )
                        echo "You Select 3.Ubuntu20.04"
                        apt install ./NXLOG-Agents/NXLog_Ubuntu_Agents/nxlog-ce_3.1.2319_ubuntu20_amd64.deb -y
                        echo "nxlog-ce_3.1.2319_ubuntu20 was installed"
                        sleep 1     
                        break;;
                        [4] )
                        echo "You Select 4.Ubuntu22.04"
                        apt install ./NXLOG-Agents/NXLog_Ubuntu_Agents/nxlog-ce_3.1.2319_ubuntu22_amd64.deb -y
                        echo "nxlog-ce_3.1.2319_ubuntu22 was installed"
                        sleep 1
                        break;;                       
                        * )
                        echo "Please Select [1-4]";;
                    esac
                done
                while true; do
                    read -p "Please Select Configuration 1. NXLog Server  2. NXLog Client ? " VERSION
                    case $VERSION in
                        [1] )
                        echo "You Select 1.NXLog Server Config"
                        cp -a ./NXLog_Config/nxlog_server.conf /etc/nxlog/nxlog.conf
                        echo "Copy NXLog_Server.conf to /etc/nxlog complete....."
                        echo "service is restarting"
                        systemctl restart nxlog
                        systemctl status nxlog 
                        sleep 1
                        break;;
                        [2] )
                        echo "You Select 2.NXLog Client Config"
                        cp -a ./NXLog_Config/nxlog_client.conf /etc/nxlog/nxlog.conf
                        echo "Copy NXLog_Client.conf to /etc/nxlog complete"
                        echo "service is restarting"
                        systemctl restart nxlog
                        systemctl status nxlog 
                        sleep 1
                        break;;
                        * )
                        echo "Please Select [1-2]";;
                    esac
                done
                break;;

                [2] )
                echo "You Select CentOS OS"
                while true; do
                    echo -e "Which type of OS \n   1.CentOS6\n   2.CentOS7\n   3.CentOS8\n   4.CentOS9"
                    read -p "Select: " VERSION
                    case $VERSION in
                        [1] )
                        echo "You Select 1.CentOS6"
                        yum install ./NXLOG-Agents/NXLog_CentOS_Agents/nxlog-ce-2.10.2150_rhel6.x86_64.rpm -y
                        echo "nxlog-ce-2.10.2150_rhel6 was installed"
                        sleep 1
                        break;;
                        [2] )
                        echo "You Select 2.CentOS7"
                        yum install ./NXLOG-Agents/NXLog_CentOS_Agents/nxlog-ce-3.1.2319_rhel7.x86_64.rpm -y
                        echo "nxlog-ce-3.1.2319_rhel7 was installed"
                        sleep 1
                        break;;
                        [3] )
                        echo "You Select 3.CentOS8"
                        yum install ./NXLOG-Agents/NXLog_CentOS_Agents/nxlog-ce-3.1.2319_rhel8.x86_64.rpm -y
                        echo "nxlog-ce-3.1.2319_rhel8 was installed"
                        sleep 1
                        break;;
                        [4]  )
                        echo "You Select 4.CentOS9"
                        yum install ./NXLOG-Agents/NXLog_CentOS_Agents/nxlog-ce-3.1.2319_rhel9.x86_64.rpm -y
                        echo "nxlog-ce-3.1.2319_rhel9 was installed"
                        sleep 1
                        break;;
                        * )
                        echo "Please Select [1-4]";;
                    esac
                done
                while true; do
                    read -p "Please Select Configuration 1. NXLog Server  2. NXLog Client ? " VERSION
                    case $VERSION in
                        [1] )
                        echo "You Select 1.NXLog Server Config"
                        cp -a ./NXLog_Config/nxlog_server.conf /etc/nxlog.conf
                        echo "Copy NXLog_Server.conf to /etc/nxlog complete....."
                        echo "service is restarting"
                        systemctl restart nxlog
                        systemctl status nxlog 
                        sleep 1
                        break;;
                        [2] )
                        echo "You Select 2.NXLog Client Config"
                        cp -a ./NXLog_Config/nxlog_client.conf /etc/nxlog.conf
                        echo "Copy NXLog_Client.conf to /etc/nxlog complete"
                        echo "service is restarting"
                        systemctl restart nxlog
                        systemctl status nxlog 
                        sleep 1
                        break;;
                        * )
                        echo "Please Select [1-2]";;
                    esac
                done
                break;;
                * )
                echo "Please Select [1-2]";;
            
            esac   
        done
        break;;
        [Nn]* )
        V3=""
        break;;
        * )
        echo "Please answer yes or no.";;
    esac
done

echo -e "Installation following package complete\n$V1\n$V2\n$V3"


echo -e "Validate Installed Packages..."
apt list --installed | grep -i nxlog
apt list --installed | grep -i forti
apt list --installed | grep -i ppp


