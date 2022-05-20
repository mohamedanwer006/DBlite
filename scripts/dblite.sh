#!/bin/bash
#******************************************************************************           
#* Created at : 19/5/2022
#******************************************************************************

# Main script for DBMS
PS3="Select the operation number : "



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


declare -a mainMenuItems=("Create Database" "Connect Database" "Drop Database" "List Database")

# Main menu

select command in "${mainMenuItems[@]}"
do
    case $command in
        "${mainMenuItems[0]}" ) 
            # createDb
            read  -p "Enter db name : " name
            . create_db.sh  $name  
            if [[ $? == 1 ]]
            then   
                echo database already exists
            else
                echo $dbName has add
            fi
        ;;

        "${mainMenuItems[1]}" ) echo "${mainMenuItems[1]}"  
       
        ;;
        
        "${mainMenuItems[2]}" ) echo "${mainMenuItems[2]}"  
        
        ;;
        
        "${mainMenuItems[3]}" ) echo "${mainMenuItems[3]}"  
        
        ;;
       
        * ) echo -e "\a Select number from options !!"
        ;;
    esac
done
