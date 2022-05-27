#!/bin/bash
#******************************************************************************
#   Created at : 19/5/2022
#******************************************************************************

#   Create Database
#   How to use
#!  `. drop_db.sh  <dbName>`
#!  return exit code 1 database not exists
#!  return exit code 0 database dropped 

#   variables
dbDir=$DB_LITE_DIR
dbName=$1

# rm -r "$dbDir/$dbName/"

rm -r "${dbDir:?}/${dbName:?}"

# Using :? will cause the command to fail if the variable is null or unset. 
# Similarly, you can use :- to set a default value if applicable
# https://www.shellcheck.net/wiki/SC2115