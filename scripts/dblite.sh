#!/bin/bash
#******************************************************************************           
#* Created at : 19/5/2022
#******************************************************************************

# Main script for DBMS
PS3="Select the operation number : "
export DB_LITE_DIR="DATABASES"

function dropMenu(){
    PS3="Select the db number : " 

    databases=($(ls $DB_LITE_DIR/)) # create array of database names as options
    databases+=("exit") # append exit option at the end of the menu options

select db in "${databases[@]}"; do
  if [[ $db == exit ]] 
  then break 
  fi
    if . drop_db.sh "$db" ;
    then
        echo "The $db is deleted"
        break
    fi
done

PS3="Select the operation number : "

}



declare -a mainMenuItems=("Create Database" "Connect Database" "Drop Database" "List Database" "Exit")

# Main menu
. print_title.sh "WELCOME TO DBLITE DBMS"
select command in "${mainMenuItems[@]}"
do
    case $command in
        "${mainMenuItems[0]}" ) 
            # createDb
            . print_title.sh "Create A New Database "
            read  -rp "Enter db name : " dbName
            if . isvalidname.sh "$dbName"
            then
                . create_db.sh  "$dbName"
                if [[ $? == 1 ]]
                then   
                    echo "database already exists!"
                else
                    echo "$dbName has been created."
                fi
            else
                echo "Invalid name of database start with letter and contain only letters ,numbers and _"
            fi
        ;;

        "${mainMenuItems[1]}" )
            . print_title.sh "Connect To Database" 
            . connect_db.sh  
       
        ;;
        
        "${mainMenuItems[2]}" )
         . print_title.sh "Drop Database"
            dropMenu
        ;;
        
        "${mainMenuItems[3]}" ) 
            . print_title.sh "List Databases"
            . list_db.sh 
        ;;
        
        "${mainMenuItems[4]}" ) 
           exit
        ;;
       
        * ) echo -e "\a Select number from options !!"
        ;;
    esac
done





