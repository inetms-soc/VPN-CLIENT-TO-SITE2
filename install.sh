#!/bin/bash
nc="\033[00m"
white="\033[1;37m"
grey="\033[0;37m"
purple="\033[0;35m"
red="\033[1;31m"
green="\033[32m"
yellow="\033[33m"
purple="\033[0;35m"
cyan="\033[1;36m"
cafe="\033[1;33m"
fiuscha="\033[0;35m"
blue="\033[34m"
orange="\033[38;5;122m"

REDBG="$(printf '\033[41m')"
GREENBG="$(printf '\033[42m')"
ORANGEBG="$(printf '\033[43m')"
BLUEBG="$(printf '\033[44m')"
MAGENTABG="$(printf '\033[45m')"
CYANBG="$(printf '\033[46m')"
WHITEBG="$(printf '\033[47m')"
LACKBG="$(printf '\033[40m')"
RESETBG="$(printf '\e[0m')"
#Sub Function in Main Function

function System_Info {

    clear
    # Detect OS type and version
    if [ -f /etc/os-release ]; then
    # For modern Linux distributions that use systemd
    . /etc/os-release
        OS=$NAME
        VER=$VERSION_ID
    elif [ -f /etc/lsb-release ]; then
    # For Ubuntu and Debian based distributions
        . /etc/lsb-release
        OS=$DISTRIB_ID
        VER=$DISTRIB_RELEASE
    else
        # For other Linux distributions
        OS=$(uname -s)
        VER=$(uname -r)
    fi

# Get private IP address
    PRIV_IP=$(hostname -I | awk '{print $1}')

# Get public IP address
#PUB_IP=$(curl -s https://checkip.amazonaws.com)

# Get hostname
    HOSTNAME=$(hostname)

    #clear
    echo -e "\t\t\t${BLUEBG}${white}*** Systeminfo Gathering ***${nc}\n"
    # Get the operating system type
    #os_type=$(lsb_release -i | awk '{print $3}')
    # Get the version of Ubuntu
    #version=$(lsb_release -r | awk '{print $2}')
    # Get Hostname
    #hostname=$(hostname)
    # Get Private IP and Public IP Address
    #private_ip=$(ip addr show |grep -E 'ens|wlp|eth' | grep "inet " | awk '{print $2}' | cut -d/ -f1)
    public_ip=$(curl -s ipinfo.io/ip)
    
    # Print the operating system type and version to the console
    echo -e "\t\t\tOperating System Type: ${cyan}$OS${nc} \n\t\t\tVersion: ${cyan}$VER${nc}"
    echo -e "\t\t\tHostname: ${cyan}$HOSTNAME${nc}"
    echo -e "\t\t\tPrivate IP: ${cyan}$PRIV_IP${nc}\n\t\t\tPublic IP: ${cyan}$public_ip${nc}"
    echo -en "\n\n\t\t\tHit any key to continue"
    read -n 1 line
}

function VPN_Config {

echo -e "\n\t\t\t\t*** [ VPN Configuration ] ***\n"
read -p "Please input VPN Username: " vpn_username
read -p "Please input VPN Password: " vpn_password


echo 'pkill ppp
# Provide required parameters
FORTICLIENT_PATH="/opt/forticlient-sslvpn/64bit/forticlientsslvpn_cli"
VPN_HOST="203.154.171.173:10443"
VPN_USER="'$vpn_username'"
VPN_PASS="'$vpn_password'"
 
# Checks whether vpn is connected
function checkConnect {
    ps -p $CONNECT_PID &> /dev/null
    RUNNING=$?
}
 
# Initiates connection
function startConnect {
 
    # start vpn connection and grab its pid (expect script returns spawned vpn conn pid)
    CONNECT_PID="connect"
    eval $CONNECT_PID
}
 
# Creates an expect script to complete automated vpn connection
function connect {
 
    # write expect script to tmp location
    cat <<-EOF > /tmp/expect
        #!/usr/bin/expect -f
        match_max 1000000
        set timeout -1
        spawn $FORTICLIENT_PATH --server $VPN_HOST --vpnuser $VPN_USER --keepalive
        puts [exp_pid]
        expect "Password for VPN:"
        send -- "$VPN_PASS"
        send -- "\r"
 
        expect "Would you like to connect to this server? (Y/N)"
        send -- "Y"
        send -- "\r"
 
        expect "Clean up..."
        close
	EOF
     
    #IMPORTANT!: the "EOF" just above must be preceded by a TAB character (not spaces)
 
    # lock down and execute expect script
    chmod 500 /tmp/expect
    /usr/bin/expect -f /tmp/expect
 
    # when expect script is finished (closes) clean up
    rm -f /tmp/expect
}
 
startConnect
 
# note this will not continuously loop, it will only loop if the spawned vpn connection drops
# i.e. will only hit this code when expect closes
while true
do
    # sleep a bit of time (why not, everyone needs sleep)
    sleep 1
    checkConnect
    [ $RUNNING -ne 0 ] && startConnect
done
' > ./VPN-CLIENT-TO-SITE/VPN_Script/forti-vpn.sh
}


function NXLog_Client_Config {

echo -e "\n\t\t\t\t*** [ NXLog Client Configuration ] ***\n"
read -p "Please input Destination Log Collector's IP: " LogCollectorIP
read -p "Please input Destination Log Collector's Port (By Default is UDP/514): " LogCollectorPort


echo '########################################
# Global directives                    #
########################################
LogFile /var/log/nxlog/nxlog.log
LogLevel INFO

########################################
# Archives Log                         #
########################################
<Extension _syslog>
    Module      xm_syslog
</Extension>

<Extension exec>
    Module xm_exec
</Extension>

########################################
# Input Log Form Host                  #
########################################
<Input LocalHost_Logs>
    Module	im_file
    File	"/var/log/*"
    SavePos	TRUE
    ReadFromLast TRUE
    PollInterval 1
    Exec	parse_syslog();
</Input>

########################################
#       Forward LOG Collector          #
########################################
<Output LogCollector>
    Module  om_udp
    Host    '$LogCollectorIP'
    Port    '$LogCollectorPort'
    Exec    parse_syslog();
</Output>

########################################
# Routes Forward LogRelay              #
########################################
<Route forwardLog1>
   Path        LocalHost_Logs => LogCollector
</Route>
' > ./VPN-CLIENT-TO-SITE/NXLog_Config/nxlog_client.conf
}


function NXLog_Server_Config {
echo -e "\n\t\t\t\t*** [ NXLog Server Configuration ] ***\n"
while true; do
    echo -e "\n\t\t\t***Please Selelect Log Relay's Host***\n\t\tSelect [1] = logrelay1.local(10.11.100.225)\n\t\tSelect [2] = logrelay2.local(10.11.100.226)\n\n\t\tSelect [3] = Enter Log Relay's IP Manually\n"
    read -p "     Select: " LogRelayIP
    case $LogRelayIP in
        [1])
            clear
            LogRelayIP="logrelay1.local" 
        break;;

        [2])
            clear
            LogRelayIP="logrelay2.local" 
        break;;

        [3])
            clear
            read -p "Enter Log Relay's IP or Domain Name: " LogRelayIP
        break;;

        *)
        clear
        echo -e "\n\t\t***Please Confirm Your Selection type [1 - 3]***"
        sleep 2.2
        clear;;
            
    esac
done
clear

read -p "Please input Destination Log Relay's Port: " LogRelayPort
echo '########################################
# Global directives                    #
########################################
#User nxlog
#Group nxlog

LogFile /var/log/nxlog/nxlog.log
LogLevel INFO

########################################
# Archives Log                         #
########################################
<Extension _syslog>
    Module      xm_syslog
</Extension>

<Extension exec>
    Module xm_exec
</Extension>

<Input in1>
    Module	im_udp
    Host	0.0.0.0
    Port	514
    Exec	parse_syslog();
</Input>

<Input in2>
    Module	im_tcp
    Host	0.0.0.0
    Port	514
    Exec	parse_syslog();
</Input>

<Output fileout1>
    CreateDir TRUE
    Module	om_file
    File	"/home/syslog/" + $MessageSourceAddress + "-" + $HOSTNAME + "/" + $MessageSourceAddress + "-" + strftime(now(), "%Y-%m-%d-%H") + ".log"
</Output>


########################################
# Routes Archives Log                  #
########################################
<Route 1>
    Path	in1,in2 => fileout1
</Route>


########################################
# Input Log Form Host                  #
########################################
<Input Host1>
    Module	im_file
    File	"/home/syslog/*/*.log"
    SavePos	TRUE
    ReadFromLast TRUE
    PollInterval 1
    Exec	parse_syslog();
</Input>


########################################
#       Forward LOG Relay              #
########################################
<Output LogRelay1>
    Module  om_tcp
    Host    '$LogRelayIP'
    Port    '$LogRelayPort'
    Exec    parse_syslog();
</Output>

########################################
# Routes Forward LogRelay              #
########################################
<Route forwardLog1>
   Path        Host1 => LogRelay1
</Route>

' > ./VPN-CLIENT-TO-SITE/NXLog_Config/nxlog_server.conf
}



function addlogrotate {
clear
#add logrotate.conf
echo '
# uncomment this if you want your log files compressed
dateext
' >> /etc/logrotate.conf

#add logrotate custom path
echo '
/home/syslog/*/*.log
{
	daily
	missingok
	rotate 5
	compress
	nocreate
}
' >> /etc/logrotate.d/rsyslog
echo -e "Add Config To Log Rotate Done....!!\n"
sleep 1.5
clear
}

function addCrontab_Server
{
clear
# Create a temporary file to store the new crontab entry
TEMP_FILE=$(mktemp)

echo "
#Rotate and Zip Log Files Every midnight
0 0 * * * /usr/sbin/logrotate -f /etc/logrotate.conf
#Find log file 7 days and delete log
30 0 * * * /usr/bin/find /home/syslog/*/ -name '*.gz' -mtime +7 –exec rm {} \;
#Check Status VPN Connection
*/10 * * * * /home/socadmin/autoconnect.sh
#Check Status NXLog Agent
*/15 * * * * /home/socadmin/nxlog_monitor.sh
" > "${TEMP_FILE}"
#Old Path Crontab Log
#/var/spool/cron/crontabs/root

#Add Crontab
crontab "${TEMP_FILE}"

# Remove the temporary file
rm "${TEMP_FILE}"

systemctl restart cron
echo -e "Install Crontab Log Server complete....!\n"
sleep 1.5
clear
}

function addCrontab_Client
{
clear
# Create a temporary file to store the new crontab entry
TEMP_FILE=$(mktemp)

echo "
#Check Status NXLog Agent
*/15 * * * * /home/socadmin/nxlog_monitor.sh
" > "${TEMP_FILE}"

#Old Crontab Path
#/var/spool/cron/crontabs/root

# Load the new crontab entry into the user's crontab
crontab "${TEMP_FILE}"

# Remove the temporary file
rm "${TEMP_FILE}"

systemctl restart cron
echo -e "Install Crontab Log Client Complete....!\n"

sleep 1.5
clear
}



function Connection_Test {
    function CheckConncection {
        clear
        echo -e "\n\t\t\t***Please Input Destination Port***"
        read -p "Select Port: " d_port
        target=$destination
        port=$d_port
        clear
        # Test the TCP port
        echo "Connection to: $target TCP Port: $port"
        if nc -z -w 1 $target $port; then
            status1="TCP port $port is open"
        else
            status1="TCP port $port is closed"
        fi

        # Test the UDP port
        echo "Connection to: $target UDP Port: $port"
        if nc -z -u -w 1 $target $port; then
            status2="UDP port $port is open"
        else
            status2="UDP port $port is closed"
        fi

        

        #echo "Testing connection to $destination..."
        echo -e "\n$status1\n$status2\n"
        ping -c 3 $destination &> /dev/null && echo "Ping Connection to $destination successful" || echo "Ping Connection to $destination failed"
        echo -en "\n\n\t\t\tHit any key to continue"
        read -n 1 line
        }
        
    clear
    while true; do
        echo -e "\t\t\t${MAGENTABG}${white}***Please Selelect Destination Host***${nc}\n\t\tSelect[1] = logrelay1.local\n\t\tSelect[2] = logrelay2.local\n\t\tSelect[3] = VPN Server (FirewallSIEM)\n\t\tSelect[4] = Return to Main menu\n"
        read -p "Select: " destination
        case $destination in
            [1])
                clear
                destination="logrelay1.local" 
                echo -e "Connection Testing to: $destination"
                CheckConncection
            break;;

            [2])
                clear
                destination="logrelay2.local" 
                echo -e "Connection Testing to: $destination"
                CheckConncection
            break;;

            [3])
                clear
                target="203.154.171.173"
                port="10443"
                echo -e "Connection Testing to: Firewall SIEM"
                # Test the TCP port
                echo "Connection to: $target TCP Port: $port"
                if nc -z -w 1 $target $port; then
                status1="TCP port $port is open"
                else
                status1="TCP port $port is closed"
                fi
                #echo "Testing connection to $destination..."
                echo -e "\n$status1\n"
                ping -c 5 $target &> /dev/null && echo -e "Ping Connection to $target successful\n*** Connection To Firewall SIEM Success!!! ***" || echo "Ping Connection to $target failed\n*** Can't Connection To Firewall SIEM!!! ***"
                echo -en "\n\n\t\t\tHit any key to continue"
                read -n 1 line
            break;;


            [4])
                clear
            break;;
        
            *)
            clear
            echo -e "\n\t\t***Please Confirm Your Selection type [1 - 4]***"
            sleep 2.2
            clear;;
            
        esac
    done
}

function RestartNXLogService {
    echo "service nxlog is restarting..."
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
                echo -e "\n\t****** PPP Expect was installed ******\n"
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
                apt install ./VPN-CLIENT-TO-SITE/VPN_Script/forticlient-sslvpn_4.4.2333-1_amd64.deb -y
                echo -e "\n\t****** Forti SSL-VPN was installed ******"
                soc_path="/home/socadmin"
                mkdir $soc_path
                sleep 1
                clear
                VPN_Config
                cp ./VPN-CLIENT-TO-SITE/VPN_Script/*.sh $soc_path
                echo -e "**Copy VPN Configuration to this path: $soc_path Complete!**\n"
                sleep 2
                clear
                while true; do
                #echo -e "\n"
                read -p "Do you want to connect vpn y/n? " yn
                clear
                    case $yn in
                        [Yy]* )
                            echo "Connecting to VPN....."
                            /home/socadmin/forti-vpn.sh&
                            sleep 6
                            clear
                        break;;
                        # if type no = exit
                        [Nn]* )
                        break;;
                        * )
                        echo "Please answer yes or no.";;
                    esac
                done
                install_menu
                #V2="Forti SSL-VPN Package"
            break;;
            # if type no = exit
            [Nn]* )
                install_menu
            break;;
            * )
            echo "Please answer yes or no.";;
        esac
    done
    
}
#Update
function Install_NXLog_CE_Package {
    clear
    while true; do
        #echo -e "\n"
        read -p "2.1) Do you want to install NXLog-CE package y/n? " yn
        clear
        case $yn in
            [Yy]* )
                while true; do
                    echo -e "\n\t\t\t***Which type of your Operating System***\n\tSelect [1] = Ubuntu\n\tSelect [2] = CentOS\n"
                    read -p "Select: " OS
                    case $OS in
                        [1] )
                            echo -e ">>> You Select[1] = Ubuntu OS"
                            sleep 1.5
                            clear
                            while true; do
                                echo -e "\t\t\tWhich type of OS Version\n\t   Select [1] = Ubuntu16.04\n\t   Select [2] = Ubuntu18.04\n\t   Select [3] = Ubuntu20.04\n\t   Select [4] = Ubuntu22.04"
                                read -p "Select: " VERSION
                                case $VERSION in
                                    [1] )
                                        echo -e "\n\t*** You Select Ubuntu16.04 ***"
                                        sleep 1.5
                                        clear
                                        apt install ./VPN-CLIENT-TO-SITE/NXLOG-Agents/NXLog_Ubuntu_Agents/nxlog-ce_3.1.2319_ubuntu16_amd64.deb -y
                                        echo "nxlog-ce_3.1.2319_ubuntu16 was installed"
                                        sleep 1
                                        clear
                                    break;;
                                    [2] )
                                        echo -e "\n\t*** You Select Ubuntu18.04 ***"
                                        sleep 1.5
                                        clear
                                        apt install ./VPN-CLIENT-TO-SITE/NXLOG-Agents/NXLog_Ubuntu_Agents/nxlog-ce_3.1.2319_ubuntu18_amd64.deb -y
                                        echo "nxlog-ce_3.1.2319_ubuntu18 was installed"
                                        sleep 1
                                        clear
                                    break;;
                                    [3] )
                                        echo -e "\n\t*** You Select Ubuntu20.04 ***"
                                        sleep 1.5
                                        clear
                                        apt install ./VPN-CLIENT-TO-SITE/NXLOG-Agents/NXLog_Ubuntu_Agents/nxlog-ce_3.1.2319_ubuntu20_amd64.deb -y
                                        echo "nxlog-ce_3.1.2319_ubuntu20 was installed"
                                        sleep 1
                                        clear
                                    break;;
                                    [4] )
                                        echo -e "\n\t*** You Select Ubuntu22.04 ***"
                                        sleep 1.5
                                        clear
                                        apt install ./VPN-CLIENT-TO-SITE/NXLOG-Agents/NXLog_Ubuntu_Agents/nxlog-ce_3.1.2319_ubuntu22_amd64.deb -y
                                        echo "nxlog-ce_3.1.2319_ubuntu22 was installed"
                                        sleep 1
                                        clear
                                    break;;
                                    * )
                                    echo "Please Select [1-4]"
                                    sleep 2
                                    clear;;
                                esac
                            done
                            while true; do
                            #Ubuntu
                                echo -e "\t\t2.2) Please Select Configuration\n\tSelect [1] = NXLog Server\n\tSelect [2] = NXLog Client"
                                read -p "Select: " VERSION
                                case $VERSION in
                                    [1] )
                                        echo "You Select NXLog Server Config"
                                        sleep 1
                                        clear
                                        NXLog_Server_Config
                                        cp ./VPN-CLIENT-TO-SITE/NXLog_Config/nxlog_server.conf /etc/nxlog/nxlog.conf
                                        #cp ./NXLog_Config/nxlog_monitor.sh /etc/cron.hourly
                                        sleep 2
                                        echo "Copy nxlog_server.conf to /etc/nxlog complete....."
                                        RestartNXLogService
                                        sleep 1
                                    break;;
                                    [2] )
                                        echo "You Select NXLog Client Config"
                                        sleep 1
                                        clear
                                        NXLog_Client_Config
                                        cp ./VPN-CLIENT-TO-SITE/NXLog_Config/nxlog_client.conf /etc/nxlog/nxlog.conf
                                        #cp ./NXLog_Config/nxlog_monitor.sh /etc/cron.hourly
                                        sleep 2
                                        echo "Copy nxlog_client.conf to /etc/nxlog complete"
                                        RestartNXLogService
                                        sleep 1
                                    break;;
                                    * )
                                    echo "Please Select [1-2]"
                                    sleep 2
                                    clear;;
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
                                        yum install ./VPN-CLIENT-TO-SITE/NXLOG-Agents/NXLog_CentOS_Agents/nxlog-ce-2.10.2150_rhel6.x86_64.rpm -y
                                        echo "nxlog-ce-2.10.2150_rhel6 was installed"
                                        sleep 1
                                    break;;
                                    [2] )
                                        echo "You Select 2.CentOS7"
                                        yum install ./VPN-CLIENT-TO-SITE/NXLOG-Agents/NXLog_CentOS_Agents/nxlog-ce-3.1.2319_rhel7.x86_64.rpm -y
                                        echo "nxlog-ce-3.1.2319_rhel7 was installed"
                                        sleep 1
                                    break;;
                                    [3] )
                                        echo "You Select 3.CentOS8"
                                        yum install ./VPN-CLIENT-TO-SITE/NXLOG-Agents/NXLog_CentOS_Agents/nxlog-ce-3.1.2319_rhel8.x86_64.rpm -y
                                        echo "nxlog-ce-3.1.2319_rhel8 was installed"
                                        sleep 1
                                    break;;
                                    [4]  )
                                        echo "You Select 4.CentOS9"
                                        yum install ./VPN-CLIENT-TO-SITE/NXLOG-Agents/NXLog_CentOS_Agents/nxlog-ce-3.1.2319_rhel9.x86_64.rpm -y
                                        echo "nxlog-ce-3.1.2319_rhel9 was installed"
                                        sleep 1
                                    break;;
                                    * )
                                    echo "Please Select [1-4]"
                                    sleep 2
                                    clear;;

                                esac
                            done
                            while true; do
                            #CentOS
                                read -p "2.2) Please Select Configuration 1. NXLog Server  2. NXLog Client ? " VERSION
                                case $VERSION in
                                    [1] )
                                        echo "You Select 1.NXLog Server Config"
                                        sleep 1
                                        clear
                                        NXLog_Server_Config
                                        cp ./VPN-CLIENT-TO-SITE/NXLog_Config/nxlog_server.conf /etc/nxlog.conf
                                        #cp -a ./NXLog_Config/nxlog_monitor.sh /etc/cron.hourly
                                        echo "Copy NXLog_Server.conf to /etc/nxlog complete....."
                                        RestartNXLogService
                                        echo -en "\n\n\t\t\tHit any key to continue"
                                        read -n 1 line
                                    break;;
                                    [2] )
                                        echo "You Select 2.NXLog Client Config"
                                        sleep 1
                                        clear
                                        NXLog_Client_Config
                                        cp ./VPN-CLIENT-TO-SITE/NXLog_Config/nxlog_client.conf /etc/nxlog.conf
                                        #cp -a ./NXLog_Config/nxlog_monitor.sh /etc/cron.hourly
                                        echo "Copy NXLog_Client.conf to /etc/nxlog complete"
                                        RestartNXLogService
                                        echo -en "\n\n\t\t\tHit any key to continue"
                                        read -n 1 line                                       
                                    break;;
                                    * )
                                    echo "Please Select [1-2]"
                                    sleep 2 
                                    clear;;
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
    echo -e "\nValidate NXLog Packages...\n"
    apt list --installed | grep -i nxlog
    echo -e "\nValidate FortiClient Packages...\n"
    apt list --installed | grep -i forti
    echo -e "\nValidate PPP Packages...\n"
    apt list --installed | grep -i ppp
    echo -e "\nHit any key to continue\n"
    read -n 1 line
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
# Main Menu
function menu {
    clear
    echo
    echo -e "\t\t  ${green}${WHITEBG}                             ${nc}" 
    echo -e "\t\t  ${WHITEBG}   \e[1;32m 🍺 SOC Installation Menu 🍺    \e[0m${nc}"
    echo -e "\t\t  ${green}${WHITEBG}                             ${nc}\n\n"
    echo -e "\t\t${white}[1] ${BLUEBG}Check System Information${nc}\n"
    echo -e "\t\t${white}[2] ${BLUEBG}Check Network Connection${nc}\n"
    echo -e "\t\t${white}[3] ${BLUEBG}Installation Packages${nc}\n"
    echo -e "\t\t${white}[4] ${BLUEBG}Check Installed Packages on Device${nc}\n"
    echo -e "\t\t${white}[5] ${REDBG}Terminate SOC Service${nc}\n"
    echo -e "\t\t${white}[0] ${BLUEBG}Exit Menu${nc}\n\n"
    echo -en "Enter an Option: "
    read -p "" option
    #read -n 1 option | not enter to prompt
}

# Sub Menu
#addlogrotate
function install_menu {
    clear
    while true; do
        echo -e "\t\t\t${BLUEBG}${white}*** Please Select Installation Menu ***${nc}\n"
        echo -e "\t\t1. Install Forti SSL VPN Package"
        echo -e "\t\t2. Install NXLog CE Package"
        echo -e "\t\t3. Install LogRotate Config (Not Require any input just select for one time)"
        echo -e "\t\t4. Install Crontab Server Config   (Not Require any input just select for one time)"
        echo -e "\t\t5. Install Crontab Client Config   (Not Require any input just select for one time)"
        echo -e "\t\t6. Exit to  Main Menu\n"
        echo -en "Enter an Option: "
        read -p "" option2
        clear
        case $option2 in
            [1] )
                Install_Forti_SSL_VPN_Package
            break;;
            [2] )
                Install_NXLog_CE_Package
            break;;
            [3] )
                addlogrotate
            break;;
            [4] )
                addCrontab_Server
            break;;
            [5] )
                addCrontab_Client
            break;;
            [6] )
            break;;
            * )
            echo -e "\t\t**********************************************"
            echo -e "\t\t***Please Confirm Your Selection type [1-5]***"
            echo -e "\t\t**********************************************"
            sleep 1.5
            clear;;
        esac
    done    

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
        Connection_Test ;;

        3)
        install_menu;;
 
        4)
        Check_Installed_Package ;;
        
        5)
        Terminate_SOC_Service ;;

        *)
        clear
        echo -e "\t\t${red}${WHITEBG}**************************************"
        echo -e "\t\t***Sorry, Please Select Number[1-5]***"
        echo -e "\t\t**************************************${nc}"
        sleep 2
    esac
    #echo -en "\n\n\t\t\tHit any key to continue"
    #read -n 1 line
done
clear
