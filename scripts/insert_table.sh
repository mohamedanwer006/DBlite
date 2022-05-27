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



for i in "${!columns[@]}"
do
	while true #Validates user input for each column and uniqueness for PK (Col 1)
	do
		read -p "Enter value for ${$column[i]} column: " value
		if [[ i -eq 0 ]]
		then
			is_unique.sh $value $i $tablePath
			is_unique_flag=$?
			if [[ $is_unique_flag -eq 1 ]]
			then
				continue
			fi
		fi
		
		if [[ "${dTypes[$i]}" -eq 0 || "${dTypes[$i]}" == "0" ]]
		then
			isnumber.sh $value 
			is_num=$?
			if [[ $is_num -eq 1 || $is_num == "1" ]]
			then
				continue
			fi
		fi
		
		if [[ "${dTypes[$i]}" -eq 1 || "${dTypes[$i]}" == "1" ]]
		then
			isvalidname.sh $value 
			is_str=$?
			if [[ $is_str -eq 1 || $is_str == "1" ]]
			then
				continue
			fi
		fi
		
		break
	done
	values[$i]=$value
done

echo $(values[@]) >> $tablePath