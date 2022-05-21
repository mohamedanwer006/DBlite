#!/bin/bash
#******************************************************************************
#   Created at : 19/5/2022
#******************************************************************************

#   Create Database
#   How to use
#!  `. create_db.sh  <dbName>`
#!  return exit code 1 database already exists
#!  return exit code 0 database created 

#   variables
dbDir=$DB_LITE_DIR
dbName=$1



# functions

function createDb(){
#   Check if database already exists
    if [ -d "$dbDir/$1" ]
    then
        return 1
    else 
        mkdir "./$dbDir/$1"
        return 0
    fi
   
} 


#   TODO: validate the name of the database

#   Check if databases directory already exists

if [ -d "$dbDir" ]
then
    
    createDb $dbName
    if [[ $? == 1 ]]
    then
    return 1
    else
    return 0
    fi
else 
    mkdir $dbDir
      createDb $dbName
    if [[ $? == 1 ]]
    then
    return 1
    else
    return 0
    fi
fi


