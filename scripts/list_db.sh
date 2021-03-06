#!/bin/bash
#******************************************************************************
#   Created at : 19/5/2022
#******************************************************************************

#   Create Database
#   How to use
#!  `. list_db.sh`
#!  output echo 'All Databases Tree' 

#   variables
dbDir=$DB_LITE_DIR
# display data using tree command
if [ -d $dbDir ]
then 
	# tree "$dbDir"

for db in  `ls $dbDir`
do
    echo "┌─ $db"
    for table in `ls $dbDir/$db `
    do
         echo -e "├────\t$table" 
    done 
done  

else
	echo "There are no databases to list."
fi
# display using for loop 
  
