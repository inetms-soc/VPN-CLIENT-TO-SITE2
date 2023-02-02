text="host1,host2,host3"

# Cut the text using the comma as a delimiter and store the first field in a variable
host=$(echo "$text" | cut -d',' -f1)

# Print the value of the variable
echo $host