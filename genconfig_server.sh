#!/bin/bash
clear
# Get the input number from the user
echo -e "\n\t\t\t\t*** NXLog Config Script for LogRelay ***\n"
read -p "Step #[1] - Enter the name of customer: " customer
sleep 0.5
clear
echo -e "\n\t\t\t\t*** "$customer" 's Port Log Recieve ***\n"
read -p "Step #[2] - Enter the log recieve port's "$customer" customer : " customer_port
sleep 0.5
clear
echo -e "\n\t\t\t\t*** "$customer" 's Hostname ***\n"
echo "Step #[3] - Enter the hostnames to retrieve [use space delimeter host]: "
echo -e "\n********************************************************************************************************"
read -a Hostname
echo "********************************************************************************************************"
echo -en "\n\n\t\t\tHit any key to confirm the hostname"
read -n 1 line
sleep 0.5
clear

HostCount=${#Hostname[@]}
#NXLOG File init
customer_path="/home/syslog/"$customer"_"$customer_port""
#Main File init
echo "" > nxlog.conf
echo "#Filters Host" > /tmp/templatesoc1
echo "
#Output Log Template" > /tmp/templatesoc2

echo "#Output Log Host Monitor Template" > /tmp/templatesoc3

echo "#Route Archive" > /tmp/templatesoc4

echo "#Route Filter Archive" > /tmp/templatesoc5

echo "
#Input Log "$customer"" > /tmp/templatesoc6

echo "" > /tmp/templatesoc7

echo "" > /tmp/templatesoc8

# INPUT Log File - FUNCTION 01
# Loop the specified number of times to get the hostname
echo "#NXLOG Config - "$customer" Customer" > nxlog.conf
echo "
#INPUT PORT
<Input ""$customer"_"$customer_port"">
    Module      im_tcp
    Host        0.0.0.0
    Port        "$customer_port"
    Exec        parse_syslog();
</Input>
" >> nxlog.conf

for ((i=0; i<$HostCount; i++))
do
# Get the hostname of the machine
    #read -p "Enter the Hostname_$i: " Hostname
    eval "Hostname$((i+1))=$Hostname"
    eval "current_hostname=${Hostname[i]}"
# Input Log - FUNCTION 4
    echo "<Input "$customer"_""HOST"$((i+1))">
    Module      im_file
    File        "\""$customer_path"/"$current_hostname"/*.log"\"
    SavePos     TRUE
    ReadFromLast TRUE
    PollInterval 1
    Exec        parse_syslog();
</Input>
" >> /tmp/templatesoc6

# Filter Host - FUNCTION02
    echo "#Filters Host$((i+1)) "\"$current_hostname\""
    <Processor filter_"$customer"_HOST"$((i+1))">
    Module      pm_filter
    Condition   \$raw_event =~ /"$current_hostname"/
</Processor>
" >> /tmp/templatesoc1
#Output Log Template - FUNCTION3
    echo "<Output fileout_"$customer"_HOST"$((i+1))">
    CreateDir TRUE
    Module      om_file
    File        "\""$customer_path"\"" + "\"/\"" + "\""$current_hostname"\"" + "\"/\"" + "\""$current_hostname"\"" + "\"-\"" + strftime(now(), "\"%Y-%m-%d-%H\"") + "\".log\""
</Output>
">> /tmp/templatesoc2

#Route Archives - FUNCTION4
echo "<Route "$customer">
    Path       ""$customer"_"$customer_port"" => filter_"$customer"_HOST"$((i+1))" => fileout_"$customer"_HOST"$((i+1))"
</Route>
">> /tmp/templatesoc5

route_host+=$(echo "$customer"_HOST"$((i+1))",)

done
#Collect Route
#clear
#Output To SIEM - FUNCTION5


# Add Monitoring Script 
echo "<Output fileout_""$customer"_MonitorHost">
    CreateDir TRUE
    Module      om_file
    File        "\""$customer_path"\"" + "\"/\"" + "\""MonitorHost"\"" + "\"/\"" + "\$HOSTNAME"
</Output>
" >> /tmp/templatesoc3


echo "# Route MonitorHost Archives
<Route ""$customer"_MonitorHost">
    Path       ""$customer"_"$customer_port"" => fileout_"$customer"_MonitorHost""
</Route>
">> /tmp/templatesoc5


#echo "#Output To SIEM"  >> nxlog.conf
echo -e "\n\t\t\t\t*** Add Number "$customer" 's Route ***\n"
read -p "Step #[4] - How many route to ERC [Default=1]: " erc_number

#sleep 0.5
clear

for ((x=1; x<=$erc_number; x++))
do
# Get the hostname of the machine
    #!/bin/bash

while true; do
    echo -e "\n\t\t\t\t*** Please Select ERC for Send "$customer"'s Log ***\n"
    echo -e "\n\t\t\t\t\t[1] ERC1 (10.11.100.129)\n\t\t\t\t\t[2] ERC2 (10.11.100.131)\n\t\t\t\t\t[3] ERC14 (10.11.100.132)\n\t\t\t\t\t[4] Softnix (10.11.102.11)\n\t\t\t\t\t[5] Enter IP manually\n\t\t\t\t\t[6] Quit"
    read -p "Step #[5] --------------- Select ERC: " ERC
    case $ERC in
        [1])
            clear
            echo -e "\t\t\tERC1 detected with IP address 10.11.100.129"
            erc_ip=10.11.100.129
            erc_name="ERC1"
        break;;

       [2])
            clear
            echo -e "\t\t\tERC2 detected with IP address 10.11.100.131"
            erc_ip=10.11.100.131
            erc_name="ERC2"
        break;;
 
       [3])
            clear
            echo -e "\t\t\tERC14 detected with IP address 10.11.100.132"
            erc_ip=10.11.100.132
            erc_name="ERC14"
        break;;

        [4])
            clear
            echo -e "\t\t\tSoftnix detected with IP address 10.11.102.11"
            erc_ip=10.11.102.11
            erc_name="Softnix"
        break;;

       [5])
            clear
            read -p "Enter Name ERC: " erc_name
            read -p "Enter the IP address: " erc_ip
        break;;

      
       [6])
            echo "Exiting the script..."
        break;;       


        *)
        clear
        echo -e "\n\t\t***Please Confirm Your Selection type [1 - 6]***"
        sleep 2.2
        clear;;
            
    esac
done

    #read -p "Enter the IP's "$erc_name": " erc_ip
    sleep 2.2
    clear
    echo -e "\n\t\t\t\t*** Please Select the Port's "$erc_name" for Send "$customer"'s Log ***\n"
    read -p "Step #[6] - Enter the Port's "$erc_name": " erc_port
    sleep 0.5
    clear
    echo -e "\n\t\t\t\t*** Please Select the name for "$customer"'s route ***\n"
    read -p "Step #[7] - Enter the Name of input host that send to "$erc_name" ip: "$erc_ip" port udp: "$erc_port": " erc_inputname
    eval "erc_name$x=$erc_name"
    eval "erc_ip$x=$erc_ip"
    eval "erc_port$x=$erc_port"
    eval "erc_inputname$x=$erc_inputname"
    eval "current_erc_name=\$erc_name$x"
    eval "current_erc_ip=\$erc_ip$x"
    eval "current_erc_port=\$erc_port$x"
    eval "current_erc_inputname=\$erc_inputname$x"

echo "#Output To $current_erc_name port $current_erc_port
<Output "$current_erc_name"_"$customer"_"$current_erc_inputname">
    Module  om_udp
    Host    "$current_erc_ip"
    Port    "$current_erc_port"
</Output>
" >> /tmp/templatesoc7

# Route To SIEM - FUNCTION 7
route_host=$(echo "$route_host" | sed 's/,$//')
#echo $route_host
#echo "#Route Log "$erc_inputname" to "$erc_name" port "$erc_port" " >> /tmp/templatesoc5
echo "#Route Log "$erc_inputname" to "$erc_name" port "$erc_port"
<Route forwardLog>
    Path      "$route_host"  => "$current_erc_name"_"$customer"_"$current_erc_inputname"
</Route>    
" >> /tmp/templatesoc8
clear

done
     
#Wite Sequence
cat /tmp/templatesoc1 >> nxlog.conf
cat /tmp/templatesoc2 >> nxlog.conf
cat /tmp/templatesoc3 >> nxlog.conf
cat /tmp/templatesoc4 >> nxlog.conf
cat /tmp/templatesoc5 >> nxlog.conf
cat /tmp/templatesoc6 >> nxlog.conf
cat /tmp/templatesoc7 >> nxlog.conf
cat /tmp/templatesoc8 >> nxlog.conf


###
# Print a message indicating that the hostnames have been saved


clear


mv ./nxlog.conf ./$customer-$customer_port.conf
cp ./$customer-$customer_port.conf /etc/nxlog/customers

cat ./$customer-$customer_port.conf

echo "Write Config and saved "$customer-$customer_port.conf" to /etc/nxlog/customers ....Done!!!"