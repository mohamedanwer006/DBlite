#!/bin/bash
#******************************************************************************
#   Created at : 19/5/2022
#   Create Database
#   How to use
#!  `. drop_table.sh  <dbName> <tableName>`
#!  return exit code 1 database not exists
#!  return exit code 0 database dropped 
#******************************************************************************

#   variables
dbDir=$DB_LITE_DIR
dbName="$1"
tableName="$2"



rm "$dbDir/$dbName/$tableName"