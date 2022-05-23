#!/bin/bash
#-------------------------------------------------
# Script to create the table in the database
#* How to use:
#* . create_table.sh <database_name> <table_name>  
#*   <database_name> is the name of the database
#*   <table_name> is the name of the table
#-------------------------------------------------

dbDir="DATABASES"

dbName=$1
tableName=$2

function createTable(){
    touch "$PWD/$dbDir/$dbName/$1"
}

# start by creating table file

createTable "$tableName"

# Add entity to table
finish=0 # variable to check if the user wants to add more entities --> 0 = yes , 1 = no

entities=() # array to store the entities
entitiesType=() # array to store the entities type

typeset -i counter=1

PS3="Select the type number : "

while [[ $finish == 0 ]]
do 

select n in "Add entity" "Finish"
do
case $n in
    "Add entity" )
        read -rp "Enter entity no $counter  : " entityName
        # Todo check entity name is unique not empty 
        # check entity name is not entered twice
        entities+=("$entityName")
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
echo "${entities[@]}" >> "$PWD/$dbDir/$dbName/$tableName"
echo "${entitiesType[@]}" >> "$PWD/$dbDir/$dbName/$tableName"

PS3="Select the command number : " 
