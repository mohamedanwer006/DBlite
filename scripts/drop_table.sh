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

PS3="Select the table number : " 
# mapfile -t tables < <(ls "$DB_LITE_DIR/$dbName/")
tables=($(ls "$DB_LITE_DIR/$dbName/")) # create array of tables names as options
tables+=("exit") # append exit option at the end of the menu options

select tbl in "${tables[@]}"
do 
    if [[ $REPLY =~ [^0-9] || $REPLY -gt ${#tables[@]} || $REPLY -lt 0 ]]
    then
        echo "Enter a number between 0 and ${#tables[@]}"
        continue
    fi

    if [[ $tbl == exit ]] 
    then break 
    fi
    
    if [[ $REPLY -lt ${#tables[@]} ]]
    then
        if rm "$dbDir/$dbName/$tbl"
        then
            echo "The $tbl is dropped from $dbName"
            break
        fi
    fi
done

PS3="Select the operation number : "
