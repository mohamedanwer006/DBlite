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


function deleteMainMenu(){
	PS3="Enter the number of the table you want to delete in: "
	tables=($(ls $1)) #create array of table names as options
	tables+=("Back") #Add option to cancel delete operation

	select t in "${tables[@]}";
	do
		if [[ $t == "Back" ]]
		then break
		fi
		deleteTableMenu $1 $t
	done
	PS3="Enter the operation number: "

}


function deleteTableMenu(){
	declare -a deleteOptions=("Choose column" "TRUNCATE"  "Cancel")
	PS3="Enter option number: "
	echo "--------------------------$t is open----------------------------"
	select uo in "${deleteOptions[@]}";
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
			
			deleteColumnMenu $1 $t $col $col_no 
		done
		fi

		if [[ $uo == "TRUNCATE" ]];
		then
			head -n 2 $1/$t > $1/$t.tmp
			mv $1/$t.tmp $1/$t
		fi
	done
	PS3="Enter option number: "
}


function deleteColumnMenu(){

	dColOptions=("Whole column" "Specify where" "Exit")
	PS3="Enter option number: "
	select dco in "${dColOptions[@]}";
	do
		case $dco in
			"${dColOptions[0]}") deleteColumn $1 $t $col $col_no ;;
			"${dColOptions[1]}") 
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
					deleteWhere $1 $t $col $col_no $new_val $cond $cond_no $filter
				done ;;
			"${dColOptions[2]}") break ;;
			*)echo "Enter one of the available option numbers:" ;;
		esac
	done
} 


function deleteColumn(){

	typeset -i n
	n=0	
	while read record
	do
		IFS="," read -r -a columns <<< $record
		if [[ n -gt 1 ]]; 
		then
			columns[$col_no]=""
		fi
		printf -v joined '%s\t' "${columns[@]}"
		echo "${joined%\t}" >> $1/buffer
		n=$n+1
	done < <(cat $1/$t)
	echo "Col  deleted!"	
}


function deleteWhere(){
	# TODO delete
	typeset -i cond_no=$cond_no+1
	typeset -i col_no=$col_no+1
	echo "${col_no} and cond ${cond_no}"
	echo "FILTERR ${filter}"
	awk -F"," -v column="$col_no" -v condition="$cond_no" -v fltr="$filter" '{ if ( $condition=="$fltr" ) { next } else { print $0 } }' $1/$t > $1/buffer
	cat $1/buffer
	echo "Update succesful!"
}

deleteMainMenu $1
