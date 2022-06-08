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

function dropMenu(){
    PS3="Select the table number : " 
# mapfile -t tables < <(ls "$DB_LITE_DIR/$dbName/")
    tables=($(ls "$DB_LITE_DIR/$dbName/")) # create array of tables names as options
    tables+=("exit") # append exit option at the end of the menu options
# TODO handel number out of indexes
select tbl in "${tables[@]}"
do
    
    if [[ $REPLY -gt ${#tables[@]} ]]
    then

        echo "Error: The number $REPLY  is not correct"
    fi

    if [[ $tbl == exit ]] 
    then break 
    fi
    
    if [[ $REPLY -lt ${#tables[@]} ]]
    then
        if . drop_table.sh "$dbName" "$tbl"
        then
            echo "The $tbl is dropped from $dbName"
            break
        fi
    fi
done

PS3="Select the operation number : "

}

function connectMenu(){
    PS3="Select the db number : " 

    databases=($(ls $dbDir)) # create array of database names as options
    databases+=("back") # append exit option at the end of the menu options

select db in "${databases[@]}"
do
# todo :if select number above the array length + 1 show error
# check if the selected number is above the array length
   
    if [[ $REPLY -gt ${#databases[@]} ]]
    then
        echo "Error: The number is not correct"
    fi
    
    if [[ $db == "back" ]] 
    then break 
    fi

    if [[ $REPLY -lt ${#databases[@]} ]]
    then
        commandMenu "$db"
    fi

done
PS3="Select the operation number : "
}


function commandMenu(){
declare -a commands=("CREATE table" "LIST table" "DROP table" "INSERT INTO table" "SELECT FROM table" "DELETE FROM table" "UPDATE into table")
commands+=("back")

PS3="Select the command number : "
local dbName=$1

# echo "----------------------------$dbName is open----------------------------" 
. print_title.sh "Connected To $dbName"
select command in "${commands[@]}"
do

if [[ $command == "back" ]] 
then break 
fi
    case $command in
        "${commands[0]}" )

            read  -rp "Enter table name : " tableName
            if . isvalidname.sh "$tableName"
            then
                . create_table.sh "$dbName" "$tableName"
                if [[ $? == 1 ]]
                then   
                    echo "$tableName already exists or you finish with out add entity"
                else
                    echo "$tableName Added"
                fi
            else
                echo "Invalid name of table start with letter and contain only letters, numbers and _"
            fi

        #####################################################33
        #   read -rp "Enter table name : " tableName
        #   . create_table.sh "$dbName" "$tableName"
          ;;

        "${commands[1]}" ) 
            . list_tables.sh "$dbName"
         ;;
    # todo : Drop table
        "${commands[2]}" ) 
            . drop_table.sh "$dbName"
         ;;
        "${commands[3]}" ) 
		. insert_table.sh "$dbDir/$dbName"
		;;
   
        "${commands[4]}" ) 
         . select_table.sh "$dbDir" "$dbName"
        ;;
    
        "${commands[5]}" )
         . delete_table.sh "$dbDir/$dbName"
         ;;
   
        "${commands[6]}" ) 
         . update_table.sh "$dbDir/$dbName" 
        ;;
        #   back command
        "${commands[7]}" ) ;;
        * ) echo -e "\a Select number from options !!" 
        ;;
    esac
done

PS3="Select the operation number : "
}


#   Start connect to database menu 
connectMenu 
