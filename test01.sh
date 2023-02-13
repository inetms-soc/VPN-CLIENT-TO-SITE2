#!/bin/bash
clear
echo "Enter some words separated by spaces: "
read -a words

wordCount=${#words[@]}

for ((i=0; i<$wordCount; i++)); do
  eval "word$((i+1))=${words[i]}"
done

echo "You entered $wordCount words:"
for ((i=1; i<=$wordCount; i++)); do
  eval "echo \$word$i"

done
echo "Total is $wordCount words:"  
