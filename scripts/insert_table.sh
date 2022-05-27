#!/bin/bash

PS3="Enter the number of the table you want to select from: "
tables=($(ls $1)) #create array of table names as options
tables+=("Back") #Add option to cancel update operation

select t in "${tables[@]}";
do
	if [[ $t == "Back" ]]
	then break
	fi
	tablePath=$1/$t
done
	
IFS="," read -r -a columns < <(head -n 1 $table)
awk -F"," '{ if (NR == 2) { print $0 } }' $tablePath > $1/data_types
IFS="," read -r -a dTypes < <(head -n 1 $1/data_types)



for column in "${columns}"
do
	read -p "Enter value for ${$column} column: " value
	values[$i]=$value
done

echo $(values[@]) >> $tablePath