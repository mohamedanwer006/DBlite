#!/bin/bash


PS3="Enter option number: "
dbDir="DATABASES"

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


function selectMainMenu(){

	PS3="Enter the number of the table you want to select from: "
	tables=($(ls "$dbDir/$dbName/")) #create array of table names as options
	tables+=("Back") #Add option to cancel update operation

	select t in "${tables[@]}";
	do
		if [[ $t == "Back" ]]
		then break
		fi
		whereMenu $1 $t
		#selectTableMenu $1 $t
	done
	PS3="Enter the operation number: "

}


function whereMenu(){
	echo "--------------------------$t is open----------------------------"
	
	echo "Will you be specifying where?"
	choices=("Yes" "No" "Exit")
	PS3="Enter option number: "
	select choice in "${choices[@]}";
	do
		case $choice in
			"${choices[0]}") columnMenu $1 $t 1 ;; #selectColumn $1 $t $col $col_no 
			"${choices[1]}") columnMenu $1 $t 0 ;;
			"${choices[2]}") break ;;
			*)echo "Enter one of the available option numbers!" ;;
		esac
	done
} 


function columnMenu(){

	if [[ $3 -eq 0 ]];
	then
		echo "Select certain columns or Select * (All)?"
		declare -a selectOptions=("Choose column(s)" "* (All)"  "Cancel")
		PS3="Enter option number: "
		select so in "${selectOptions[@]}";
		do
			if [[ $so == "Cancel" ]]
			then break
			fi

			if [[ $so == "* or All" ]]; then
				awk 'NR!=2' $1/$t
				echo "Selected All Successfully!"
			fi
			
			if [[ $so == "Choose column(s)" ]]
			then
				IFS="," read -r -a columns < <(head -n 1 $1/$t)
				columns+=("Back")
			select col in "${columns[@]}";
			do
				if [[ $col == "Back" ]]
				then break
				fi
				
				echo "Enter the column numbers to appear in select: "
				
				selectColumn $1 $t $REPLY
			done
			fi
		done
		PS3="Enter option number: "
		
		return
	fi
	
	
	echo "Select certain columns or Select * (All)?"
	declare -a selectOptions=("Choose column(s)" "* (All)"  "Cancel")
	PS3="Enter option number: "
	select so in "${selectOptions[@]}";
	do
		if [[ $so == "Cancel" ]]
		then break
		fi
		
		if [[ $so == "Choose column(s)" ]]
		then
			IFS="," read -r -a columns < <(head -n 1 "$dbDir/$dbName/$t")
			columns+=("Back")
		select col in "${columns[@]}";
		do
			if [[ $col == "Back" ]]
			then break
			fi
			read -r -p "Enter the column number: " selection #columns to appear after select executes
			
			#index_of $col columns #get column index
			
			echo "Next, select where column."
			IFS="," read -r -a cond_columns < <(head -n 1 $1/$t)
			select cond_column in "${cond_columns[@]}"
			do	
			echo > /dev/null
			done

			read -r -p "Enter search criteria/value for that column: " criteria

			grep $criteria $1/$t | cut -d"," -f$selection | cat
		done
		fi

		if [[ $so == "* or All" ]]; then
			awk -F"," 'NR!=2' $1/$t > $1/$t.tmp
			cat $1/$t.tmp
		fi
	done
	PS3="Enter option number: "
}


function selectColumn(){
	awk -F"," 'NR!=2' $1/$t > $1/$t.tmp
	cut -d"," -f$3 $1/$t.tmp | cat
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









































			
			
				#columns+=("Cancel")
				#echo "Enter column number for the where clause: "
				#select cond in "${columns[@]}";
				#do
				#	if [[ $cond == "Cancel" ]];
				#	then
				#		break
				#	fi

				#	index_of $cond columns #get index of condition column
				#	cond_no=$? #condition column index

				#	read -r -p "Enter where/filter value: " filter
					#Cond is the criteria, cond_no is that col num, filter is the value to look for
				#	selectWhere $1 $t $cond $cond_no $filter
				#done
			
			#selectColumnMenu $1 $t $selection #$col $col_no
