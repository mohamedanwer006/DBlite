#!/bin/bash
#******************************************************************************
#   Created at : 19/5/2022
#******************************************************************************

#   Create Database
#   How to use
#!  `. drop_db.sh  <dbName>`
#!  return exit code 1 database not exists
#!  return exit code 0 database dropped 

function dropDb(){
#   variables
dbDir=$DB_LITE_DIR
dbName=$1

# rm -r "$dbDir/$dbName/"

rm -r "${dbDir:?}/${dbName:?}"

# Using :? will cause the command to fail if the variable is null or unset. 
# Similarly, you can use :- to set a default value if applicable
# https://www.shellcheck.net/wiki/SC2115
}

function dropMenu(){
    databases=($(ls "$PWD"/"$DB_LITE_DIR")) # create array of database names as options
    declare -a args=(
        --title "Welcome to dblite DBMS " --notags --fb --menu "Select database u want to delete 👇" 20 60 "${#databases[@]}"
    )
    # create array of menu commands
    for item in "${databases[@]}"; do
        args+=("$item" "$item")
    done
    
    db=$(whiptail "${args[@]}" 3>&1 1>&2 2>&3 )
    if [[ $? == 1  ]]
    then
        return
    fi
    if dropDb "$db" ;
    then
        msgWidget "The $db is deleted"
    fi
}

dropMenu
