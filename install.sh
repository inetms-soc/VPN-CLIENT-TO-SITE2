#!/bin/bash

#Sub Function in Main Function
function System_Info {
    clear
    echo -e "Systeminfo Gethering....\n"
    # Get the operating system type
    os_type=$(lsb_release -i | awk '{print $3}')
    # Get the version of Ubuntu
    version=$(lsb_release -r | awk '{print $2}')
    # Get Hostname
    hostname=$(hostname)
    # Get Private IP and Public IP Address
    private_ip=$(ip addr show |grep -E 'ens|wlp|eth' | grep "inet " | awk '{print $2}' | cut -d/ -f1)
    public_ip=$(curl -s ipinfo.io/ip)
    
    # Print the operating system type and version to the console
    echo -e "Operating system type: $os_type \nVersion: $version"
    echo -e "Hostname: $hostname"
    echo -e "Private IP: $private_ip\nPublic IP: $public_ip"
}

function Connection_Test {
    clear
    while true; do
        echo -e "\n\t\t\t***Please Selelect Destination Host***\n\tSelect[1] = logrelay1.local\n\tSelect[2] = logrelay2.local\n"
        read -p "Select: " destination
        case $destination in
            [1])
                destination="logrelay1.local" 
                echo -e "Connection Testing to $destination.....\n"
            break;;

            [2])
                destination="logrelay2.local" 
                echo -e "Connection Testing to $destination.....\n"
            break;;

            *)
            echo -e "\t***Please Confirm Your Selection type [1 or 2]***"
            sleep 2.2
            clear;;
            
        esac
    done

    echo -e "\n\t\t\t***Please Input Destination Port***"
    read -p "Select Port: " d_port
    target=$destination
    port=$d_port

    # Test the TCP port
    echo "Testing TCP port $port on $target..."
    if nc -z -w 1 $target $port; then
        echo "TCP port $port is open"
    else
        echo "TCP port $port is closed"
    fi

    # Test the UDP port
    echo "Testing UDP port $port on $target..."
    if nc -zu -w 1 $target $port; then
        echo "UDP port $port is open"
    else
        echo "UDP port $port is closed"
    fi

    #!/bin/bash
    # Test the connection to google.com
    echo "Testing connection to logrelay1.local..."
    ping -c 3 logrelay1.local &> /dev/null && echo "Connection to logrelay1.local successful" || echo "Connection to logrelay1.local failed"

    # Test the connection to facebook
    echo "Testing connection to logrelay2.local..."
    ping -c 3 logrelay2.local &> /dev/null && echo "Connection to logrelay2.local successful" || echo "Connection to logrelay2.local failed"


}

function RestartNXLogService {
    echo "service is restarting"
    systemctl restart nxlog
    systemctl status nxlog
}

#Main Function
function Install_Forti_SSL_VPN_Package {
    clear
    while true; do
        #echo -e "\n"
        read -p "1.1) Do you want to install PPP Expect package y/n? " yn
        clear
        case $yn in
            [Yy]* )
                echo "Installing PPP Package....."
                apt install ppp expect -y
                echo -e "\n\t******PPP Expect was installed******\n"
                sleep 1.5
                clear
            break;;
            # if type no = exit
            [Nn]* )
            break;;
            * )
            echo "Please answer yes or no.";;
        esac
    done
    while true; do
        read -p "1.2) Do you want to install Forti SSL VPN Package y/n? " yn
        clear
        case $yn in
            [Yy]* )
                echo "Installing Forti SSL-VPN Package....."
                apt install ./VPN_Script/forticlient-sslvpn_4.4.2333-1_amd64.deb -y
                echo -e "\n\t******Forti SSL-VPN was installed******"
                soc_path="/home/socadmin"
                cp -a ./VPN_Script/*.sh $soc_path
                echo -e "**Copy VPN Configuration to this path: $soc_path Complete!**\n"
                sleep 1.5
                clear
                #V2="Forti SSL-VPN Package"
            break;;
            # if type no = exit
            [Nn]* )
            break;;
            * )
            echo "Please answer yes or no.";;
        esac
    done
    
}

function Install_NXLog_CE_Package {
    clear
    while true; do
        #echo -e "\n"
        read -p "2.1) Do you want to install NXLog-CE package y/n? " yn
        clear
        case $yn in
            [Yy]* )
                while true; do
                    echo -e "\n\t\t\t***Which type of your Operating System***\n\tSelect[1] = Ubuntu\n\tSelect[2] = CentOS\n"
                    read -p "Select: " OS
                    case $OS in
                        [1] )
                            echo -e ">>> You Select[1] = Ubuntu OS"
                            sleep 1.5
                            clear
                            while true; do
                                echo -e "\t\t\tWhich type of OS Version\n\t   Select[1] = Ubuntu16.04\n\t   Select[2] = Ubuntu18.04\n\t   Select[3] = Ubuntu20.04\n\t   Select[4] = Ubuntu22.04"
                                read -p "Select: " VERSION
                                case $VERSION in
                                    [1] )
                                        echo -e "\n\t***You Select 1.Ubuntu16.04***"
                                        sleep 1.5
                                        clear
                                        apt install ./NXLOG-Agents/NXLog_Ubuntu_Agents/nxlog-ce_3.1.2319_ubuntu16_amd64.deb -y
                                        echo "nxlog-ce_3.1.2319_ubuntu16 was installed"
                                        sleep 1
                                        clear
                                    break;;
                                    [2] )
                                        echo -e "\n\t***You Select 1.Ubuntu18.04***"
                                        sleep 1.5
                                        clear
                                        apt install ./NXLOG-Agents/NXLog_Ubuntu_Agents/nxlog-ce_3.1.2319_ubuntu18_amd64.deb -y
                                        echo "nxlog-ce_3.1.2319_ubuntu18 was installed"
                                        sleep 1
                                        clear
                                    break;;
                                    [3] )
                                        echo -e "\n\t***You Select 1.Ubuntu20.04***"
                                        sleep 1.5
                                        clear
                                        apt install ./NXLOG-Agents/NXLog_Ubuntu_Agents/nxlog-ce_3.1.2319_ubuntu20_amd64.deb -y
                                        echo "nxlog-ce_3.1.2319_ubuntu20 was installed"
                                        sleep 1
                                        clear
                                    break;;
                                    [4] )
                                        echo -e "\n\t***You Select 1.Ubuntu22.04***"
                                        sleep 1.5
                                        clear
                                        apt install ./NXLOG-Agents/NXLog_Ubuntu_Agents/nxlog-ce_3.1.2319_ubuntu22_amd64.deb -y
                                        echo "nxlog-ce_3.1.2319_ubuntu22 was installed"
                                        sleep 1
                                        clear
                                    break;;
                                    * )
                                    echo "Please Select [1-4]";;
                                esac
                            done
                            while true; do
                                read -p "2.2) Please Select Configuration 1. NXLog Server  2. NXLog Client ? " VERSION
                                case $VERSION in
                                    [1] )
                                        echo "You Select 1.NXLog Server Config"
                                        cp -a ./NXLog_Config/nxlog_server.conf /etc/nxlog/nxlog.conf
                                        echo "Copy NXLog_Server.conf to /etc/nxlog complete....."
                                        RestartNXLogService
                                        sleep 1
                                    break;;
                                    [2] )
                                        echo "You Select 2.NXLog Client Config"
                                        cp -a ./NXLog_Config/nxlog_client.conf /etc/nxlog/nxlog.conf
                                        echo "Copy NXLog_Client.conf to /etc/nxlog complete"
                                        RestartNXLogService
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
                                echo -e "\t\tWhich type of OS \n\t   1.CentOS6\n\t   2.CentOS7\n\t   3.CentOS8\n\t   4.CentOS9"
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
                                read -p "2.2) Please Select Configuration 1. NXLog Server  2. NXLog Client ? " VERSION
                                case $VERSION in
                                    [1] )
                                        echo "You Select 1.NXLog Server Config"
                                        cp -a ./NXLog_Config/nxlog_server.conf /etc/nxlog.conf
                                        echo "Copy NXLog_Server.conf to /etc/nxlog complete....."
                                        RestartNXLogService
                                        sleep 1
                                    break;;
                                    [2] )
                                        echo "You Select 2.NXLog Client Config"
                                        cp -a ./NXLog_Config/nxlog_client.conf /etc/nxlog.conf
                                        echo "Copy NXLog_Client.conf to /etc/nxlog complete"
                                        RestartNXLogService
                                        sleep 1
                                    break;;
                                    * )
                                    echo "Please Select [1-2]";;
                                esac
                            done
                        break;;
                        * )
                            clear
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
}
function Check_Installed_Package {
    clear
    echo -e "\nValidate Installed Packages...\n"
    apt list --installed | grep -i nxlog
    apt list --installed | grep -i forti
    apt list --installed | grep -i ppp
}
function Terminate_SOC_Service {
    clear
    while true; do
        echo -e "\n"
        read -p "Are you sure to uninstall SOC Service y/n? " yn
        case $yn in
            [Yy]* )
                unset soc_path
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
                echo -e "Terminate Service Done...!"
            break;;
            # if type no = exit
            [Nn]* )
            break;;
            * )
            echo "Please Confirm Your Selection type yes or no.";;
        esac
    done
    #!/bin/bash
    
    
}

function menu {
    clear
    echo
    echo -e "\t\t\tInstallation Menu\n"
    echo -e "\t1. System Information"
    echo -e "\t2. Install Forti SSL VPN Package"
    echo -e "\t3. Install NXLog CE Package"
    echo -e "\t4. Check Installed Package on Device"
    echo -e "\t5. Terminate SOC Service"
    echo -e "\t6. Connection Test"
    echo -e "\t0. Exit Menu\n\n"
    echo -en "\t\tEnter an Option: "
    read -p "" option
    #read -n 1 option | not enter to prompt
}

while [ 1 ]
do
    menu
    case $option in
        0)
        clear
        break ;;
        1)
        System_Info ;;

        2)
        Install_Forti_SSL_VPN_Package ;;
        
        3)
        Install_NXLog_CE_Package ;;
        
        4)
        Check_Installed_Package ;;
        
        5)
        Terminate_SOC_Service ;;

        6)
        Connection_Test ;;
    
        *)
        clear
        echo "Sorry, Please Select Number[1-5]" ;;
    esac
    echo -en "\n\n\t\t\tHit any key to continue"
    read -n 1 line
done
clear