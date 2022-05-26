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



function connectMenu(){
    PS3="Select the db number : " 

    databases=($(ls $dbDir)) # create array of database names as options
    databases+=("back") # append exit option at the end of the menu options

select db in "${databases[@]}"; do
# todo :if select number above the array length + 1 show error

  if [[ $db == "back" ]] 
  then break 
  fi
  commandMenu "$db"
done
PS3="Select the operation number : "
}


function commandMenu(){
declare -a commands=("CREATE table" "LIST table" "DROP table" "INSERT INTO table" "SELECT FROM table" "DELETE FROM table" "UPDATE into table")
commands+=("back")

PS3="Select the command number : "
local dbName=$1

echo "----------------------------$dbName is open----------------------------" 
select command in "${commands[@]}"
do
if [[ $command == "back" ]] 
then break 
fi
    case $command in
        "${commands[0]}" )
          read -rp "Enter table name : " tableName
          . create_table.sh "$dbName" "$tableName"
          ;;
    # todo : List tables
        "${commands[1]}" ) 
            . list_tables.sh "$dbName"
         ;;
    # todo : Drop table
        "${commands[2]}" ) echo "${command[2]}" ;;
    # todo : Insert into table
        "${commands[3]}" ) echo "${command[3]}" ;;
    # todo : Select from table
        "${commands[4]}" ) echo "${command[4]}" ;;
    # todo : Delete from table
        "${commands[5]}" ) echo "${command[5]}" ;;
    # todo : Update into table
        "${commands[6]}" ) echo "${command[6]}" ;;
        #   back command
        "${commands[7]}" ) ;;
        * ) echo -e "\a Select number from options !!" 
        ;;
    esac
done

PS3="Select the operation number : "
}


#   menu 
connectMenu 
