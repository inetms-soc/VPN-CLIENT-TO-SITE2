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



# Loop the specified number of times to get the hostname
echo "#Define Hostname" > nxlog.conf
echo "#Filters Host" > /tmp/templatesoc1
echo "#Output Log Template" > /tmp/templatesoc2
echo "#Route Archive" > /tmp/templatesoc3
echo "#Input Log "$customer"" > /tmp/templatesoc4
echo "" > /tmp/templatesoc5

#echo "#Define Hostname" >> nxlog.conf

for ((i=1; i<=$number; i++))
do
# Get the hostname of the machine
    read -p "Enter the Hostname_$i: " Hostname

    eval "Hostname$i=$Hostname"
    eval "current_hostname=\$Hostname$i"
# Append the hostname to the file
    echo "define "$customer"_HOST"$i" $current_hostname" >> nxlog.conf

    route_host+=$(echo "%"$customer"_HOST"$i"%,") 
    #eval "route_host$i=$route_host"
    #eval "current_route_host=\$route_host$i"


#Filter Host
echo "#Filters Host$i "\"$current_hostname\""
<Processor filter_%"$customer"_HOST"$i"%>
    Module      pm_filter
    Condition   \$raw_event =~ /"$current_hostname"/
</Processor>
" >> /tmp/templatesoc1


#Output Log Template Fusion
echo "<Output fileout_%"$customer"_HOST"$i"%>
    CreateDir TRUE
    Module      om_file
    File        "\"%"$customer"_PATH%\"" + "\"/\"" + "\"%"$customer"_HOST"$i"%\"" + "\"/\"" + "\"%"$customer"_HOST"$i"%\"" + "\"-\"" + strftime(now(), "\"%Y-%m-%d-%H\"") + "\".log\""
</Output>
" >> /tmp/templatesoc2


#Route Archives
echo "<Route "$customer">
    Path       ""$customer"_"$customer_port"" => filter_%"$customer"_HOST"$i"% => fileout_%"$customer"_HOST"$i"%
</Route>
" >> /tmp/templatesoc3

#Input Log Customer
echo "<Input "$customer"_%"$customer"_HOST"$i"%>
    Module      im_file
    File        "\"%"$customer"_PATH%/%"$customer"_HOST$i%/*.log\""
    SavePos     TRUE
    ReadFromLast TRUE
    PollInterval 1
    Exec        parse_syslog();
</Input>
" >> /tmp/templatesoc4
clear
done


echo "define "$customer"_PATH" "/home/syslog/"$customer"_"$customer_port"" >> nxlog.conf

echo "
#INPUT PORT
<Input ""$customer"_"$customer_port"">
    Module      im_tcp
    Host        0.0.0.0
    Port        "$customer_port"
    Exec        parse_syslog();
</Input>
" >> nxlog.conf

cat /tmp/templatesoc1 >> nxlog.conf
cat /tmp/templatesoc2 >> nxlog.conf
cat /tmp/templatesoc3 >> nxlog.conf

route_host=$(echo "$route_host" | sed 's/,$//')
#echo $route_host

echo "#Output To SIEM"  >> nxlog.conf
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

# Append the hostname to the file
echo "<Output "$current_erc_name"_"$customer"_"$current_erc_inputname">
    Module  om_udp
    Host    "$current_erc_ip"
    Port    "$current_erc_port"
</Output>
" >> nxlog.conf

echo "#Route Log "$erc_inputname" to "$erc_name" port "$erc_port" " >> /tmp/templatesoc5
echo "<Route forwardLog>
    Path      "$route_host"  => "$current_erc_name"_"$customer"_"$current_erc_inputname"
</Route>    
" >> /tmp/templatesoc5
clear
done

cat /tmp/templatesoc4 >> nxlog.conf
cat /tmp/templatesoc5 >> nxlog.conf


###
# Print a message indicating that the hostnames have been saved
echo "Write Config and saved to nxlog.conf file"

clear
cat nxlog.conf

