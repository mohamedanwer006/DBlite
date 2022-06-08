#!/bin/bash
#-------------------------------------------------
# Script to create the table in the database
#* How to use:
#* . list_tables.sh <database_name>   
#*   <database_name> is the name of the database
#*   <table_name> is the name of the table
#-------------------------------------------------

dbDir="DATABASES"

dbName=$1

for i in `ls "$dbDir/$dbName"`
do
    echo "$i" >> .list.tmp
    head -n 2 "$dbDir/$dbName/$i" >> .list.tmp 2>/dev/null
    # TODO fix ERR
    echo " " >> .list.tmp
done

whiptail --textbox .list.tmp 20 60 --fb
rm .list.tmp 2>/dev/null