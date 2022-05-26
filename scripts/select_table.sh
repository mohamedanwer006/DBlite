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


function selectMainMenu(){
	PS3="Enter the number of the table you want to select from: "
	tables=($(ls $1)) #create array of table names as options
	tables+=("Back") #Add option to cancel update operation

	select t in "${tables[@]}";
	do
		if [[ $t == "Back" ]]
		then break
		fi
		selectTableMenu $1 $t
	done
	PS3="Enter the operation number: "

}


function selectTableMenu(){
	declare -a selectOptions=("Choose column" "* or All"  "Cancel")
	PS3="Enter option number: "
	echo "--------------------------$t is open----------------------------"
	select so in "${selectOptions[@]}";
	do
		if [[ $so == "Cancel" ]]
		then break
		fi
		
		if [[ $so == "Choose column" ]]
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
			
			selectColumnMenu $1 $t $col $col_no
		done
		fi

		if [[ $so == "* or All" ]]; then
			cat $1/$t
		fi
	done
	PS3="Enter option number: "
}


function selectColumnMenu(){

	sColOptions=("Whole column" "Specify where" "Exit")
	PS3="Enter option number: "
	select sco in "${sColOptions[@]}";
	do
		case $sco in
			"${sColOptions[0]}") selectColumn $1 $t $col $col_no ;;
			"${sColOptions[1]}") 
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

					read -r -p "Enter where filter value: " filter
					#Cond is the criteria, cond_no is that col num, filter is the value to look for
					selectWhere $1 $t $col $col_no $new_val $cond $cond_no $filter
				done ;;
			"${sColOptions[2]}") break ;;
			*)echo "Enter one of the available option numbers:" ;;
		esac
	done
} 


function selectColumn(){
	typeset -i c=$col_no+1
	cat $1/$t | cut -d"," -f"${c}"	
}


function selectWhere(){
	
	typeset -i cond_no=$cond_no+1
	typeset -i col_no=$col_no+1
	#echo "${col_no} and cond ${cond_no}"
	#echo "FILTERR ${filter}"
	awk -F"," -v column="$col_no" -v condition="$cond_no" -v -v fltr="$filter" '{ if ( $condition=="$fltr" ) {  print $0 } else { next } }' $1/$t > $1/buffer
	cat $1/buffer
	echo "Update succesful!"
}

selectMainMenu $1
