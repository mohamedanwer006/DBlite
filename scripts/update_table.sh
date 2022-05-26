#!/bin/bash


PS3="Enter option number: "


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


function updateMainMenu(){
	PS3="Enter the number of the table you want to update: "
	tables=($(ls $1)) #create array of table names as options
	tables+=("Back") #Add option to cancel update operation

	select t in "${tables[@]}";
	do
		if [[ $t == "Back" ]]
		then break
		fi
		updateTableMenu $1 $t
	done
	PS3="Enter the operation number: "

}


function updateTableMenu(){
	declare -a updateOptions=("Choose column" "Cancel")
	PS3="Enter option number: "
	echo "--------------------------$t is open----------------------------"
	select uo in "${updateOptions[@]}";
	do
		if [[ $uo == "Cancel" ]]
		then break
		fi
		
		if [[ $uo == "Choose column" ]]
		then
			IFS="," read -r -a columns < <(head -n 1 $1/$t)
			columns+=("Back")
		select col in "${columns[@]}";
		do
			if [[ $col == "Back" ]]
			then break
			fi

			index_of $col columns #get column index
			col_no=$? #column index
			
			read -p "Enter the new value you would like to set: " new_val
			updateColumnMenu $1 $t $col $col_no $new_val
		done
		fi
	done
	PS3="Enter option number: "
}


function updateColumnMenu(){

	uColOptions=("Whole column" "Specify where" "Exit")
	PS3="Enter option number: "
	select uco in "${uColOptions[@]}";
	do
		case $uco in
			"${uColOptions[0]}") updateColumn $1 $t $col $col_no $new_val ;;
			"${uColOptions[1]}") 
				IFS="," read -r -a columns < <(head -n 1 $1/$t)
				columns+=("Cancel")
				select cond in "${columns[@]}";
				do
					if [[ $cond == "Cancel" ]];
					then
						break
					fi

					index_of $cond columns #get index of condition column
					cond_no=$? #condition column index

					read -p "Enter the value you would like to filter records by: " filter
					#Cond is the criteria, cond_no is that col num, filter is the value to look for
					updateWhere $1 $t $col $col_no $new_val $cond $cond_no $filter
				done ;;
			"${uColOptions[2]}") break ;;
			*)echo "Enter one of the available option numbers:" ;;
		esac
	done
} 


function updateColumn(){

	typeset -i n
	n=0	
	while read record
	do
		IFS="," read -r -a columns <<< $record
		if [[ n -gt 1 ]]; 
		then
			columns[$col_no]="${new_val}"
		fi
		printf -v joined '%s\t' "${columns[@]}"
		echo "${joined%\t}" >> $1/buffer
		n=$n+1
	done < <(cat $1/$t)
	echo "Col  updated!"	
}


function updateWhere(){
	
	typeset -i cond_no=$cond_no+1
	typeset -i col_no=$col_no+1
	echo "${col_no} and cond ${cond_no}"
	echo "FILTERR ${filter}"
	awk -F"," -v column="$col_no" -v condition="$cond_no" -v new_value="$new_val" -v fltr="$filter" '{ if ( $condition=="$fltr" ) { $column=$new_value ; print $0 } else { print $0 } }' $1/$t > $1/buffer
	cat $1/buffer
	echo "Update succesful!"
}

updateMainMenu $1
