#!/bin/bash

# Get the input number from the user
echo "#Define Hostname"
read -p "Enter the name of customer: " customer
read -p "Enter the number of hostnames to retrieve: " number


# Loop the specified number of times to get the hostname
echo "" > nxlog.conf
echo "#Define Hostname" >> nxlog.conf

for ((i=1; i<=$number; i++))
do
    # Get the hostname of the machine
    read -p "Enter the Hostname_$i: " Hostname
    eval "Hostname$i=$Hostname"
    # Append the hostname to the file
    echo "define "$customer"_HOST"$i" $Hostname$i" >> nxlog.conf


done

echo "#INPUT PORT"
read -p "Enter the recieve port's "$customer" : " customer_port

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

for ((i=1; i<=$number; i++))
do
echo "
#Filters Host
<Processor "filter_"$customer"_HOST"$i"">
    Module      pm_filter
    Condition   $raw_event =~ /"$Hostname$i"/
</Processor>
" >> nxlog.conf
done
###
# Print a message indicating that the hostnames have been saved
echo "Write Config and saved to nxlog.conf file"


