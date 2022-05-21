#!/bin/bash
#******************************************************************************           
#* Created at : 19/5/2022
#******************************************************************************

# Main script for DBMS
PS3="Select the operation number : "
export DB_LITE_DIR="DATABASES"


#   Functions

# function createDb(){
#     local name
#     read  -p "Enter db name : " name
       
#         . create_db.sh  $name  
#         if [[ $? == 1 ]]
#         then   
#             echo database already exists
#         else
#             echo $dbName has add
#         fi
#  
# }


function dropMenu(){
    PS3="Select the db number : " 

    databases=($(ls $DB_LITE_DIR)) # create array of database names as options
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



declare -a mainMenuItems=("Create Database" "Connect Database" "Drop Database" "List Database")

# Main menu

select command in "${mainMenuItems[@]}"
do
    case $command in
        "${mainMenuItems[0]}" ) 
            # createDb
            read  -rp "Enter db name : " dbName
            # shellcheck source=create_db.sh
            . create_db.sh "$dbName" 
            if [[ $? == 1 ]]
            then   
                echo database already exists
            else
                echo "$dbName has add"
            fi
        ;;

        "${mainMenuItems[1]}" ) 
            . connect_db.sh  
       
        ;;
        
        "${mainMenuItems[2]}" )
            dropMenu
        ;;
        
        "${mainMenuItems[3]}" ) 
            . list_db.sh 
        ;;
       
        * ) echo -e "\a Select number from options !!"
        ;;
    esac
done





