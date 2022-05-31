#!/bin/bash

# firstArg="$PWD/DATABASES/mo/"
# set -- "$firstArg"

PS3="Enter the number of the table : "
mapfile -t tables < <(ls "$1") # create array of table names as options
# tables=($(ls "$1")) #create array of table names as options

tables+=("Back") #Add option to cancel update operation

select t in "${tables[@]}";
do
	# check if user selected Back option
	if [[ $t == "Back" ]]
	then break
	fi

    # check if user selected a valid option
	if [[ $REPLY =~ [^0-9] || $REPLY -gt ${#tables[@]} || $REPLY -lt 0 ]]
    then
        echo "Enter number from 0 to ${#tables[@]}"
        continue
    fi

    
    tablePath="$1/$t"

	IFS="," # set the delimiter to ","
	# read first two lin from table file and add to array
	columns=($(head -n 1 "$tablePath"))

	#  read the second line from table file and add to array
	dataTypes=($(head -n 2 "$tablePath" | tail -n 1))

	for i in "${!columns[@]}"
	do
		while true
		do
			read -rp "Enter value for ${columns[$i]} column: " value

            # check for fist column (PK) uniqueness
            if [[ $i -eq 0 ]]
            then
                #  get the first colum values from table file start from line 3 to end
                colValues=($(tail -n +3 "$tablePath" | cut -d "," -f 1))
                # check if the entered value is already exist in the column
                if [[ "${colValues[*]}" =~ "$value" ]]
                then
                    echo "The value is already exist in the table"
                    continue
                fi
            
            fi
            # check if the entered value matches the integer data type form the dataTypes array
            if [[ ${dataTypes[$i]} -eq 0 && ! $value =~ ^[0-9]+$ ]]
            then
                echo "Enter a valid integer value"
                continue
            fi

            # check if the entered value matches the string data type form the dataTypes array
            if [[ ${dataTypes[$i]} -eq 1 && ! $value =~ ^[a-zA-Z]+$ ]]
            then
                echo "Enter a valid string value"
                continue
            fi

			break
		done
		# add value to array
		values+=("$value")
		
	done

IFS=","	;	echo "${values[*]}"	>>	"$tablePath"
values=() # reset values array for next call as the script run as sourcing
done
