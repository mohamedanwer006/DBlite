#!/bin/bash
#******************************************************************************
#   Created at : 19/5/2022
#   Create Database
#   How to use
#!  `. drop_table.sh  <dbName> `

#******************************************************************************

#   variables
dbDir=$DB_LITE_DIR
dbName="$1"

# PS3="Select the table number : " 
# mapfile -t tables < <(ls "$DB_LITE_DIR/$dbName/")
tables=($(ls "$DB_LITE_DIR/$dbName/")) # create array of tables names as options

declare -a args=(
    --title "Drop table from $dbName " --notags --fb --menu "Select table to delete 👇" 20 60 "${#tables[@]}"
)
# create array of menu commands
for item in "${tables[@]}"; do
    args+=("$item" "$item")
done


if [[ $? == 1  ]]
then
return  #exit program
fi
tbl=$(whiptail "${args[@]}" 3>&1 1>&2 2>&3 )
        if rm "$dbDir/$dbName/$tbl"
        then
            msgWidget "The $tbl is dropped from $dbName"
fi