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
if [ -d "$PWD/$dbDir" ]
then 
	tree "$dbDir" >> .list.tmp

    # substitute "directories" to "Database" in only last line of .list.tmp
    sed -i '$s/directories/Database/g' .list.tmp
    sed -i '$s/files/Tables/g' .list.tmp

    # sed -i 's/directories/Database/g' .list.tmp

    # sed -i '$d' .list.tmp
    

# for db in  `ls "$PWD/$dbDir"`
# do
#     echo "┌─ $db" >> .list.tmp
#     for table in `ls $PWD/$dbDir/$db `
#     do
#          echo -e "├────\t$table"  >> .list.tmp
#     done 
#     echo "└──────────────── " >> .list.tmp
# done  

else
	echo "There are no databases to list." >> .list.tmp
fi
# display using for loop 
whiptail --textbox .list.tmp 30 40 --fb --scrolltext
rm .list.tmp 2>/dev/null 
