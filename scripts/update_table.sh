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
		then exit 0
		fi
		whereMenu $1 $t
		#updateTableMenu $1 $t
		exit 0
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
			"${choices[0]}") updateMenu $1 $t 1 ;; 
			"${choices[1]}") updateMenu $1 $t 0 ;;
			"${choices[2]}") return ;;
			*)echo "Enter one of the available option numbers!" ;;
			"${choices[2]}") return ;;
			*) echo "Enter one of the available option numbers!" ;;
		esac
		return
	done
} 


function updateMenu(){
	
	if [[ $3 -eq 0 ]];
	then
		declare -a updateOptions=("Choose column" "Cancel")
		PS3="Enter option number: "
		echo "--------------------------$t is open----------------------------"
		select uo in "${updateOptions[@]}";
		do
			if [[ $uo == "Cancel" ]]
			then return
			fi
			
			if [[ $uo == "Choose column" ]]
			then
				IFS="," read -r -a columns < <(head -n 1 $1/$t)
				columns+=("Back")
				select column in "${columns[@]}";
				do
					if [[ $column == "Back" ]]
					then return
					fi

					index_of $column columns #get column index
					column_index=$? #column index
					read -p "Enter the new value you would like to set: " new_val
					#updateColumnMenu $1 $t $col $col_no $new_val
					typeset -i column_num=$column_index+1
									
					awk -F"," -v column_number="$column_num" -v new_value="$new_val" 'BEGIN { OFS="," } { if ( NF==column_number ) { $column_number=new_value; print $0 } else { print $0 } }' $1/$t > $1/$t.tmp
					
					mv $1/$t.tmp $1/$t
					exit 0
				done
			fi
			exit 0
		done
		PS3="Enter option number: "
	fi
	
	# here if specifiying where 
	declare -a updateOptions=("Choose column" "Cancel")
		PS3="Enter option number: "
		echo "--------------------------$t is open----------------------------"
		select uo in "${updateOptions[@]}";
		do
			if [[ $uo == "Cancel" ]]
			then return
			fi
			
			if [[ $uo == "Choose column" ]]
			then
				IFS="," read -r -a columns < <(head -n 1 $1/$t)
				columns+=("Back")
				select column in "${columns[@]}";
				do
					if [[ $column == "Back" ]]
					then return
					fi
			
					PS3="Next, select the column for the where clause: "
					IFS="," read -r -a cond_columns < <(head -n 1 $1/$t)
					select cond_column in "${cond_columns[@]}"
					do	
						typeset -i cond_column_index
						typeset -i cond_column_number

						index_of $cond_column cond_columns #get column index
						cond_column_index=$?
						read -r -p "Enter filter criteria/value for that column: " criteria
						
						cond_column_number=$cond_column_index+1		
						record_nums=( $(tail -n +3 $1/$t | cut -d, -f$cond_column_number | grep -n $criteria | cut -f1 -d:) )
						
						index_of $column columns #get index of column to be updated
						column_index=$? #column index
						read -p "Enter the new value you would like to set: " new_val
						
						# check for first column (PK) uniqueness
						if [[ $column_index -eq 0 ]]
						then
							#  get the first colum values from table file start from line 3 to end
							colValues=($(tail -n +3 "$tablePath" | cut -d "," -f 1))
							# check if the entered value already exists in the column
							if [[ "${colValues[*]}" =~ "$new_val" ]]
							then
								echo "The entered value already exists in the table."
								return
							fi
						fi
						
						# check if the entered value matches the integer data type form the dataTypes array
						if [[ ${dataTypes[$column_index]} -eq 0 && ! $new_val =~ ^[0-9]+$ ]]
						then
							echo "Not a valid integer value."
							return
						fi

						# check if the entered value matches the string data type form the dataTypes array
						if [[ ${dataTypes[$column_index]} -eq 1 && ! $new_val =~ ^[a-zA-Z]+$ ]]
						then
							echo "Not a valid string value."
							return
						fi
						
						typeset -i column_num=$column_index+1
						
						for record_num in "${record_nums[@]}"; 
						do
							typeset -i rec_num=$record_num+2
							awk -F"," -v record_number=$rec_num -v column_number="$column_num" -v new_value="$new_val" 'BEGIN { OFS="," } { if ( NR==record_number ) { $column_number=new_value; print $0 } }' $1/$t #> $1/$t.tmp
						done
						
						#mv $1/$t.tmp $1/$t
						return
					done
					return
				done
				return
			fi
			return
		done
		PS3="Enter option number: "
}

updateMainMenu $1
