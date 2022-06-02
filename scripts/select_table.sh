#!/bin/bash


PS3="Enter option number: "
dbDir="DATABASES"

dbName=$2

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
		then exit 0
		fi
		whereMenu $dbDir/$dbName $t
		exit 0
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
			"${choices[2]}") return ;;
			*) echo "Enter one of the available option numbers!" ;;
			"${choices[2]}") return ;;
			*) echo "Enter one of the available option numbers!" ;;
		esac
		return
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
			then return
			fi

			if [[ $so == "* (All)" ]]; then
				awk 'NR!=2' "$1/$t"
			fi
			
			if [[ $so == "Choose column(s)" ]]
			then
				IFS="," read -r -a columns < <(head -n 1 "$dbDir/$dbName/$t")
				columns+=("Back")
			select col in "${columns[@]}";
			do
				if [[ $col == "Back" ]]
				then return
				fi
				
				echo "Enter the column numbers to appear in select: "
				
				selectColumn $1 $t $REPLY # or $col instead of $REPLY
				return
			done
			fi
			return
		done
		PS3="Enter option number: "
		
		return
	fi
	
	
	# here if user will select where
	declare -a selectOptions=("Choose column(s)" "* (All)"  "Cancel")
	PS3="Select certain columns or Select * (All)?"
	select so in "${selectOptions[@]}";
	do
		if [[ $so == "Cancel" ]]
		then return
		fi
		
		if [[ $so == "Choose column(s)" ]]
		then
			IFS="," read -r -a columns < <(head -n 1 "$1/$t")
			columns+=("Back")
		select col in "${columns[@]}";
		do
			if [[ $col == "Back" ]]
			then return
			fi
			
			read -r -p "Enter the column numbers to appear after select executes.\n Seperate column numbers by commas and no spaces.\n Do not put a comma before the first column number\n or after the last column number. Example --> 2,5,6 : " selection #columns to appear after select executes
			
			PS3="Next, select the column for the where clause: "
			IFS="," read -r -a cond_columns < <(head -n 1 $1/$t)
			select cond_column in "${cond_columns[@]}"
			do	
				typeset -i cond_column_index
				typeset -i cond_column_number

				index_of $cond_column cond_columns #get column index
				cond_column_index=$? 
				read -r -p "Enter search criteria/value for that column: " criteria
				
				# Now use table($1/$t), condition_column and its index to filter records, selection to cut fields/columns that were selected
				cond_column_number=$cond_column_index+1		
				record_nums=( $(tail -n +3 $1/$t | cut -d, -f$cond_column_number | grep -n $criteria | cut -f1 -d:) )
				
				touch $1/$t.tmp
				cut -d, -f$selection $1/$t | sed -n "1p" > $1/$t.tmp

				for record_num in "${record_nums[@]}"; 
				do
					tail -n +3 $1/$t | cut -d, -f$selection | sed -n "${record_num}p" >> $1/$t.tmp # Remember to cut with $selection
				done
				
				cat "$1/$t.tmp"
				rm "$1/$t.tmp"
				return
			done
		done
		fi

		if [[ $so == "* (All)" ]]; then
			IFS="," read -r -a columns < <(head -n 1 "$1/$t")
			columns+=("Back")
		select col in "${columns[@]}";
		do
			if [[ $col == "Back" ]]
			then return
			fi
			
			#read -r -p "Enter the column numbers to appear after select executes.\n Seperate column numbers by commas and no spaces.\n Do not put a comma before the first column number\n or after the last column number. Example --> 2,5,6 : " selection #columns to appear after select executes
			
			PS3="Next, select the column for the where clause: "
			IFS="," read -r -a cond_columns < <(head -n 1 $1/$t)
			select cond_column in "${cond_columns[@]}"
			do	
				typeset -i cond_column_index
				typeset -i cond_column_number

				index_of $cond_column cond_columns #get column index
				cond_column_index=$? 
				read -r -p "Enter search criteria/value for that column: " criteria
				
				# Now use table($1/$t), condition_column and its index to filter records, selection to cut fields/columns that were selected
				cond_column_number=$cond_column_index+1		
				record_nums=( $(tail -n +3 $1/$t | cut -d, -f$cond_column_number | grep -n $criteria | cut -f1 -d:) )
				
				touch $1/$t.tmp
				sed -n "1p" $1/$t > $1/$t.tmp

				for record_num in "${record_nums[@]}"; 
				do
					tail -n +3 $1/$t | sed -n "${record_num}p" >> $1/$t.tmp # Remember to cut with $selection
				done
				
				cat $1/$t.tmp
				rm $1/$t.tmp
				return
			done
		done
		fi
	done
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
	echo "Update successful!"
}

selectMainMenu $1