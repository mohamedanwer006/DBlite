#!/bin/bash
#-------------------------------------------------
# Script to create the table in the database
#* How to use:
#* . create_table.sh <database_name> <table_name>
#*   <database_name> is the name of the database
#*   <table_name> is the name of the table
#* return exit code 1 table already exists
#* return exit code 0 table created
#* return exit code 3 table not saved
#-------------------------------------------------

dbDir="DATABASES"

dbName=$1
tableName=$2



if [ -f "$PWD/$dbDir/$dbName/$tableName"  ]
then
    return 1 # return 1 table already exists
fi


function createTable(){
    touch "$PWD/$dbDir/$dbName/$1"
}

# start by creating table file

createTable "$tableName"
# check if table name exist

# Add entity to table
finish=0 # variable to check if the user wants to add more entities --> 0 = yes , 1 = no
entities=() # array to store the entities
entitiesType=() # array to store the entities type

typeset -i counter=1

PS3="Select the command number : "

    while [[ $finish == 0 ]]
    do
        
        select n in "Add entity" "Finish"
        do
            case $n in
                "Add entity" )
                    while true
                    do
                        read -rp "Enter entity no $counter  : " entityName
                        # check if the entity name is valid
                        if . isvalidname.sh "$entityName"
                        then
                            # check entity name is not entered twice
                            if . isinlist.sh "$entityName" "${entities[@]}"
                            then
                                echo "Entity name already exists"
                            else
                                entities+=("$entityName")
                                break
                            fi
                        else
                            echo "Invalid name of entity start with letter and contain only letters ,numbers and _"
                        fi
                    done
                    break
                ;;
                "Finish" )
                    finish=1
                    break
                ;;
                *) echo "invalid option";;
            esac
        done
        
        if [[ $finish == 1 ]]
        then
            break
        fi
        
        select t in "String" "Integer"
        do
            case $t in
                "String" )
                    entitiesType+=("String")
                    break
                ;;
                "Integer" )
                    entitiesType+=("Integer")
                    break
                ;;
                * ) echo "invalid option";;
            esac
        done
        counter=$counter+1
    done

    # Add metadata to table
    # First line contains the columns names
    # Second line contains the types of the columns
    IFS=","; echo "${entities[*]}" >> "$PWD/$dbDir/$dbName/$tableName"
    IFS=","; echo "${entitiesType[*]}" >> "$PWD/$dbDir/$dbName/$tableName"
    sed -i 's/String/1/g' "$PWD/$dbDir/$dbName/$tableName" # replace String with 1
    sed -i 's/Integer/0/g' "$PWD/$dbDir/$dbName/$tableName" # replace Integer with 0
    PS3="Select the command number : "
    # check if the user finish before he enter the entity 
    if [[ ${#entities[@]}  == 0  ]]
    then

        rm  "$PWD/$dbDir/$dbName/$tableName"
        
        return 1
    fi 
    
    return 0 # return 0 if table created successfully