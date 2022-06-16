#!/bin/bash
#-------------------------------------------------
# Script to create the table in the database
#* How to use:
#* . list_tables.sh <database_name>   
#*   <database_name> is the name of the database
#*   <table_name> is the name of the table
#-------------------------------------------------


function list(){
dbDir="DATABASES"

dbName=$1

tables=($(ls "$PWD/$DB_LITE_DIR/$dbName/")) # create array of tables names as options
echo "tables: ${tables[*]}" >> log2
# check that tables array dose not have \n
# remove \n from array and add space 
# tables=(${tables[*]//$'\n'/ })
# create a new tables array without the \n


# for i in "${!tables[@]}"
# do
#     tables[$i]=$(echo "${tables[$i]}" | tr -d '\n')
# done


for i in "${tables[@]}"
do
    echo "$i" >> .list.tmp
    tbl=$i
    echo $tbl >> logs
    # read first line of file i
    # echo "$(head -n 1 $PWD/$DB_LITE_DIR/$dbName/$i)" >> .list.tmp
#    columns=($(head -n 1 "$PWD/$DB_LITE_DIR/$dbName/$i"))
#    columns=($(head -n 1 "$PWD/$DB_LITE_DIR/$dbName/$i"))
    # echo "${columns[@]}" >> .list.tmp 
    echo  "$PWD/$dbDir/$dbName/$tbl" >> logs
    head -n 2 "$PWD/$dbDir/$dbName/$tbl" >> .list.tmp 
    cat "$PWD/$dbDir/$dbName/$tbl" >> log2
    # sed '2d' "$PWD/$dbDir/$dbName/$i" >> .list.tmp 
    # # TODO fix ERR
    echo " " >> .list.tmp
done

whiptail --title "List $dbName " --textbox .list.tmp 20 60 --fb
rm .list.tmp 2>/dev/null

}

list "$1"
tables=()
i=""
