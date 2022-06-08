#!/bin/bash


PS3="Enter option number: "

dbName=$1

function index_of(){
	my_array=$2[@]
	arr=("${!my_array}")
	value=$1

	for i in "${!arr[@]}"; do
		if [[ "${arr[$i]}" = "${value}" ]]; 
		then
			return $i
		fi
	done
}


function deleteMainMenu(){
	PS3="Enter the number of the table you want to delete in: "
	tables=($(ls $1)) #create array of table names as options
	tables+=("Back") #Add option to cancel delete operation

	select t in "${tables[@]}";
	do
		if [[ $t == "Back" ]]
		then return
		fi
		deleteTableMenu $1 $t
		PS3="Enter option number: "
		return
	done
	PS3="Enter the operation number: "
}


function deleteTableMenu(){
	echo "Will you be specifying where?"
	deleteOptions=("Yes -> Choose column" "No -> TRUNCATE"  "Cancel")
	PS3="Enter option number: "
	echo "--------------------------$t is open----------------------------"
	select deleteOption in "${deleteOptions[@]}";
	do
		if [[ $deleteOption == "Cancel" ]]
		then return
		fi
		
		if [[ $deleteOption == "Yes -> Choose column" ]]
		then
			IFS="," read -r -a cond_columns < <(head -n 1 $1/$t)
			columns+=("Back")
			
			select cond_column in "${cond_columns[@]}"
			do	
				typeset -i cond_column_index
				typeset -i cond_column_number

				index_of $cond_column cond_columns #get column index
				cond_column_index=$? 
				read -r -p "Enter search criteria/value for that column: " criteria
				
				# Now use table($1/$t), condition_column and its index to filter records to delete
				cond_column_number=$cond_column_index+1		
				record_nums=( $(tail -n +3 $1/$t | cut -d, -f$cond_column_number | grep -n -v $criteria | cut -f1 -d:) )
				
				touch $1/$t.tmp
				sed -n "1,2p" $1/$t > $1/$t.tmp
				
				for record_num in "${record_nums[@]}"; 
				do
					tail -n +3 $1/$t | sed -n "${record_num}p" >> $1/$t.tmp
				done
				
				mv $1/$t.tmp $1/$t
				return
			done
		fi

		if [[ $deleteOption == "No -> TRUNCATE" ]];
		then
			sed -i '3,$d' $1/$t
		fi
		
		return
	done
	PS3="Enter option number: "
}

deleteMainMenu $1
