#!/bin/bash
#----------------------------------------------------------------------------
#   Created at : 21/5/2022
#   Create Database
#   How to use
#*  `. connect_db.sh `
#----------------------------------------------------------------------------



#   variables
dbDir=$DB_LITE_DIR
dbName=$1

function msgWidget(){
    whiptail --msgbox  --fb "$1" 12 50
}


function connectMenu(){
    databases=($(ls $dbDir)) # create array of database names as options
    
    declare -a args=(
        --title "Connect to database " --notags --fb --menu "Select database from below 👇" 20 60 "${#databases[@]}"
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
    commandMenu "$db"
}


function commandMenu(){
    
    while  true
    do

        declare -a commands=("CREATE table" "LIST table" "DROP table" "INSERT INTO table" "SELECT FROM table" "DELETE FROM table" "UPDATE into table")
        
        local dbName=$1
        
        declare -a args=(
            --title "$dbName is open"  --notags --fb --menu "Select option from below 👇" 20 60 "${#commands[@]}"
        )
        # create array of menu commands
        for item in "${commands[@]}"; do
            args+=("$item" "$item")
        done
        
        command=$(whiptail "${args[@]}" 3>&1 1>&2 2>&3 )
        # if [[ $? == 1  ]]
        # then
        #     return
        # fi
        if [[ $? == 1  ]]
        then
            break #exit program
        fi
        case $command in
            "${commands[0]}" )
                
                # read  -rp "Enter table name : " tableName
                # tableName=$(whiptail --title "Create A New Table "  --fb --inputbox "Table Name" 12 50 3>&1 1>&2 2>&3 )
                tableName=$(whiptail --title "Create A New Table "  --fb --inputbox "Table Name" 12 50 3>&1 1>&2 2>&3 )
                
                if . isvalidname.sh "$tableName"
                then
                    . create_table.sh "$dbName" "$tableName"
                    if [[ $? == 1 ]]
                    then
                        msgWidget "$tableName already exists or you Finish with out add entity"
                        # echo "$tableName already exists or you Finish with out add entity"
                    else
                        msgWidget "$tableName Added"
                    fi
                else
                    msgWidget "Invalid name of table start with letter and contain only letters, numbers and _"
                    # echo "Invalid name of table start with letter and contain only letters, numbers and _"
                fi
            ;;
            
            "${commands[1]}" )
                list_tables.sh "$dbName"
            ;;
            # todo : Drop table
            "${commands[2]}" )
                drop_table.sh "$dbName"
            ;;
            "${commands[3]}" )
                 insert_table.sh "$dbDir/$dbName"
            ;;
            
            "${commands[4]}" )
                select_table.sh "$dbDir" "$dbName"
            ;;
            
            "${commands[5]}" )
                 delete_table.sh "$dbDir/$dbName"
            ;;
            
            "${commands[6]}" )
                 update_table.sh "$dbDir/$dbName"
            ;;
        esac
    done
}


#   Start connect to database menu
connectMenu
