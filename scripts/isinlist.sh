#!/bin/bash
#-------------------------------------------------
#   Script to check if item is in the list
#* How to use:
#* . isinlist.sh <item> <list>
#*   <item> is the item to check
#*   <list> is the list to check
#*   return 0 if item is in the list
#*   return 1 if item is not in the list
#------------------------------------------------- 

item=$1
list=$2
status=1


for i in "${list[@]}"
do
    if [[ "$i" = "$item" ]]
    then
        status=0
        break
    fi
done


if [[ $status == 0 ]]
then
    return 0
else
    return 1
fi



