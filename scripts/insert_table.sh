#!/bin/bash

function msgWidget(){
    whiptail --msgbox  --fb "$1" 12 50
}

mapfile -t tables < <(ls "$1") # create array of table names as options

declare -a args=(
    --title "Insert into  "  --notags --fb --menu "Select table from below 👇" 20 60 "${#tables[@]}"
)
# create array of menu commands
for item in "${tables[@]}"; do
    args+=("$item" "$item")
done

t=$(whiptail "${args[@]}" 3>&1 1>&2 2>&3 )

tablePath="$1/$t"
cancel=0
IFS="," # set the delimiter to ","
# read first two line from table file and add to array
columns=($(head -n 1 "$tablePath"))

#  read the second line from table file and add to array
dataTypes=($(head -n 2 "$tablePath" | tail -n 1))

for i in "${!columns[@]}"
do
    while true
    do
        value=$(whiptail --title "INSERT INTO " --ok-button "OK"  --fb --inputbox "Enter value for ( ${columns[$i]} )" 12 50 3>&1 1>&2 2>&3 )
        if [[ $? == 1 ]]
        then 
        cancel=1
        break 
        fi
        
        # check for first column (PK) uniqueness
        if [[ $i -eq 0 ]]
        then
            #  get the first colum values from table file start from line 3 to end
            colValues=($(tail -n +3 "$tablePath" | cut -d "," -f 1))
            # check if the entered value is already exist in the column
            if [[ "${colValues[*]}" =~ "$value" ]]
            then
                # echo "The value is already exist in the table"
                msgWidget "The value is already exist in the table"
                continue
            fi
            
        fi
        # check if the entered value matches the integer data type form the dataTypes array
        if [[ ${dataTypes[$i]} -eq 0 && ! $value =~ ^[0-9]+$ ]]
        then
            msgWidget  "Enter a valid integer value"
            # echo "Enter a valid integer value"
            continue
        fi
        
        # check if the entered value matches the string data type form the dataTypes array
        if [[ ${dataTypes[$i]} -eq 1 && ! $value =~ ^[a-zA-Z]+$ ]]
        then
            msgWidget "Enter a valid string value"
            # echo "Enter a valid string value"
            continue
        fi
        
        break
    done
    # add value to array
    values+=("$value")
    
done

if [[ cancel -eq 1 ]]
then
return
else
IFS=","	;	echo "${values[*]}"	>>	"$tablePath"
values=() # reset values array for next call as the script run as sourcing
PS3="Select the operation number : "
fi
return 0
