#!/bin/bash
clear
# Get the input number from the user
echo "#Define Hostname"
read -p "Enter the name of customer: " customer
sleep 0.5
clear
echo "#INPUT PORT"
read -p "Enter the log recieve port's "$customer" customer : " customer_port
sleep 0.5
clear
echo "#INPUT NUMBER OF HOSTNAME"
read -p "Enter the number of hostnames to retrieve: " number
sleep 0.5
clear

#NXLOG File init
customer_path="/home/syslog/"$customer"_"$customer_port""
#Main File init
echo "" > nxlog.conf
echo "#Filters Host" > /tmp/templatesoc1
echo "#Output Log Template" > /tmp/templatesoc2
echo "#Route Archive" > /tmp/templatesoc3
echo "#Input Log "$customer"" > /tmp/templatesoc4
echo "" > /tmp/templatesoc5

# INPUT Log File - FUNCTION 01
# Loop the specified number of times to get the hostname
echo "#Auto Config NXLOG - Demo01" > nxlog.conf
echo "
#INPUT PORT
<Input ""$customer"_"$customer_port"">
    Module      im_tcp
    Host        0.0.0.0
    Port        "$customer_port"
    Exec        parse_syslog();
</Input>
" >> nxlog.conf
for ((i=1; i<=$number; i++))
do
# Get the hostname of the machine
    read -p "Enter the Hostname_$i: " Hostname
    eval "Hostname$i=$Hostname"
    eval "current_hostname=\$Hostname$i"
# Input Log - FUNCTION 4
    echo "

<Input "$customer"Host"$i">
    Module      im_file
    File        "\"/home/syslog/"$customer"/"$current_hostname"/*.log"\"
    SavePos     TRUE
    ReadFromLast TRUE
    PollInterval 1
    Exec        parse_syslog();
</Input>" >> /tmp/templatesoc4
# Filter Host - FUNCTION02
    echo "
#Filters Host$i "\"$current_hostname\""
    <Processor filter_"$customer"_HOST"$i">
    Module      pm_filter
    Condition   \$raw_event =~ /"$current_hostname"/
</Processor>" >> /tmp/templatesoc1
#Output Log Template - FUNCTION3

    echo "

<Output fileout_"$customer"_HOST"$i">
    CreateDir TRUE
    Module      om_file
    File        "\""$customer_path"\"" + "\"/\"" + "\""$current_hostname"\"" + "\"/\"" + "\""$current_hostname"\"" + "\"-\"" + strftime(now(), "\"%Y-%m-%d-%H\"") + "\".log\""
</Output>">> /tmp/templatesoc2

#Route Archives - FUNCTION4
echo "

<Route "$customer">
    Path       ""$customer"_"$customer_port"" => filter_"$customer"_HOST"$i" => fileout_"$customer"_HOST"$i"
</Route>" >> /tmp/templatesoc3

route_host+=$(echo "$customer"_HOST"$i",)
done
#Collect Route
clear
#Output To SIEM - FUNCTION5


#echo "#Output To SIEM"  >> nxlog.conf
read -p "Enter the number of route to ERC: " erc_number
for ((x=1; x<=$erc_number; x++))
do
# Get the hostname of the machine
    read -p "Enter the Name of ERC: " erc_name
    read -p "Enter the IP's "$erc_name": " erc_ip
    read -p "Enter the Port's "$erc_name": " erc_port
    read -p "Enter the Name of input host that send to "$erc_name" ip: "$erc_ip" port udp: "$erc_port" : " erc_inputname
    eval "erc_name$x=$erc_name"
    eval "erc_ip$x=$erc_ip"
    eval "erc_port$x=$erc_port"
    eval "erc_inputname$x=$erc_inputname"
    eval "current_erc_name=\$erc_name$x"
    eval "current_erc_ip=\$erc_ip$x"
    eval "current_erc_port=\$erc_port$x"
    eval "current_erc_inputname=\$erc_inputname$x"

echo "<Output "$current_erc_name"_"$customer"_"$current_erc_inputname">
    Module  om_udp
    Host    "$current_erc_ip"
    Port    "$current_erc_port"
</Output>
" >> /tmp/templatesoc5
done
     
#Wite Sequence
cat /tmp/templatesoc1 >> nxlog.conf
cat /tmp/templatesoc2 >> nxlog.conf
cat /tmp/templatesoc3 >> nxlog.conf

# Route To SIEM - FUNCTION 7
route_host=$(echo "$route_host" | sed 's/,$//')
#echo $route_host
echo "#Route Log "$erc_inputname" to "$erc_name" port "$erc_port" " >> /tmp/templatesoc5
echo "<Route forwardLog>
    Path      "$route_host"  => "$current_erc_name"_"$customer"_"$current_erc_inputname"
</Route>    
" >> /tmp/templatesoc5
clear

cat /tmp/templatesoc4 >> nxlog.conf
cat /tmp/templatesoc5 >> nxlog.conf


###
# Print a message indicating that the hostnames have been saved
echo "Write Config and saved to nxlog.conf file"

clear


mv ./nxlog.conf ./$customer-$customer_port.conf
cp ./$customer-$customer_port.conf /etc/nxlog

cat ./$customer-$customer_port.conf
echo "Copy config to /etc/nxlog/customers .... Done!"