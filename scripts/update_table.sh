#!/bin/bash


PS3="Enter option number: "

function index_of(){
    my_array=$2[@]
    arr=("${!my_array}")
    value=$1
    for i in "${!arr[@]}"; do
        if [[ "${arr[$i]}" = "${value}" ]];
        then
            return "$i"
        fi
    done
}


function updateMainMenu(){
    tables=($(ls "$1")) #create array of table names as options

    declare -a args=(
        --title "UPDATE INTO table" --notags --fb --menu "Select table from below 👇" 20 60 "${#tables[@]}"
    )
    # create array of menu commands
    for item in "${tables[@]}"; do
        args+=("$item" "$item")
    done
    t=$(whiptail "${args[@]}" 3>&1 1>&2 2>&3 )
    
    if [[ $? == 1  ]]
    then
        return
    fi
  
    whereMenu "$1" "$t"
}

function whereMenu(){

    choices=("Yes" "No")

    declare -a args=(
        --title "UPDATE INTO ( $t ) " --notags --fb --menu "Will you be specifying where?👇" 20 60 "${#choices[@]}"
    )
    # create array of menu commands
    for item in "${choices[@]}"; do
        args+=("$item" "$item")
    done
    choice=$(whiptail "${args[@]}" 3>&1 1>&2 2>&3 )
    
    if [[ $? == 1  ]]
    then
        return
    fi

    case $choice in
        "${choices[0]}") updateMenu "$1" "$t" 1 ;;
        "${choices[1]}") updateMenu "$1" "$t" 0 ;;
    esac

}


function updateMenu(){
    
    if [[ $3 -eq 0 ]];
    then
        
        IFS="," read -r -a columns < <(head -n 1 "$1"/"$t")
        
        declare -a args=(
            --title "UPDATE INTO table" --notags --fb --menu "Choose column from below 👇" 20 60 "${#columns[@]}"
        )
        # create array of menu commands
        for item in "${columns[@]}"; do
            args+=("$item" "$item")
        done
        column=$(whiptail "${args[@]}" 3>&1 1>&2 2>&3 )
        
        if [[ $? == 1  ]]
        then
            return
        fi
        
        
        index_of "$column" columns #get column index
        column_index=$? #column index
        
        if [[ $column_index == 0 ]]
        then
            # echo "Cannot update entire PK field. Exiting..."
            msgWidget "⛔ Cannot update entire PK field. ⛔"
            return
        fi
        
        new_val=$(whiptail --title "UPDATE INTO $t " --ok-button "OK"  --fb --inputbox "Enter the new value ($column)" 12 50 3>&1 1>&2 2>&3 )
        
        IFS="," read -r -a dataTypes < <(head -n 2 "$1"/"$t" | tail -n 1)
        
        # check if the entered value matches the integer data type form the dataTypes array
        if [[ ${dataTypes[$column_index]} -eq 0 && ! $new_val =~ ^[0-9]+$ ]]
        then
           
            msgWidget "❕ Enter a valid integer value ❕"
            return
        fi
        
        # check if the entered value matches the string data type form the dataTypes array
        if [[ ${dataTypes[$column_index]} -eq 1 && ! $new_val =~ ^[a-zA-Z]+$ ]]
        then
            msgWidget "❕Enter a valid string value❕"
            return
        fi
        
        typeset -i column_num=$column_index+1
        
        awk -F"," -v column_number="$column_num" -v new_value="$new_val" 'BEGIN { OFS="," } { if ( NR>2 ) { $column_number=new_value; print $0 } else { print $0 } }' $1/$t > $1/.f.csv
        
        mv "$1"/.f.csv "$1"/"$t"
        msgWidget "✅ Update Column ($column) Done ✅"
        return

    fi
    
   
    IFS="," read -r -a columns < <(head -n 1 "$1"/"$t")
    
    declare -a args=(
        --title "UPDATE INTO table" --notags --fb --menu "Choose column from below 👇" 20 60 "${#columns[@]}"
    )
    # create array of menu commands
    for item in "${columns[@]}"; do
        args+=("$item" "$item")
    done
    column=$(whiptail "${args[@]}" 3>&1 1>&2 2>&3 )
    
    if [[ $? == 1  ]]
    then
        return
    fi
    
    PS3="Next, select the column for the where clause: "
    IFS="," read -r -a cond_columns < <(head -n 1 "$1"/"$t")
    
    
    declare -a args=(
        --title "UPDATE INTO ($t)" --notags --fb --menu "select the column for the where clause: 👇" 20 60 "${#cond_columns[@]}"
    )
    # create array of menu commands
    for item in "${cond_columns[@]}"; do
        args+=("$item" "$item")
    done
    cond_column=$(whiptail "${args[@]}" 3>&1 1>&2 2>&3 )
    
    if [[ $? == 1  ]]
    then
        return
    fi
    

    typeset -i cond_column_index
    typeset -i cond_column_number
    
    index_of "$cond_column" cond_columns #get column index
    cond_column_index=$?
    
    
    criteria=$(whiptail --title "UPDATE INTO $t " --ok-button "OK"  --fb --inputbox "Enter value for ($column)" 12 50 3>&1 1>&2 2>&3 )
    
    
    cond_column_number=$cond_column_index+1
    record_nums=( $(tail -n +3 "$1"/"$t" | cut -d, -f"$cond_column_number" | grep -n ^"$criteria"$ | cut -f1 -d:) )
    
    index_of "$column" columns #get index of column to be updated
    column_index=$? #column index
    
    if [[ $column_index == 0 ]]
    then
        # echo "Cannot update PK field. Exiting..."
        msgWidget "⛔ Cannot update entire PK field. ⛔"
        
        return
    fi
    
    new_val=$(whiptail --title "UPDATE INTO $t " --ok-button "OK"  --fb --inputbox "Enter the new value you would like to set ($column)" 12 50 3>&1 1>&2 2>&3 )

    IFS="," read -r -a dataTypes < <(head -n 2 "$1"/"$t" | tail -n 1)
    

    # check if the entered value matches the integer data type form the dataTypes array
    if [[ ${dataTypes[$column_index]} -eq 0 && ! $new_val =~ ^[0-9]+$ ]]
    then
        msgWidget  "❕Enter a valid integer value❕"
        return
    fi
    
    # check if the entered value matches the string data type form the dataTypes array
    if [[ ${dataTypes[$column_index]} -eq 1 && ! $new_val =~ ^[a-zA-Z]+$ ]]
    then
        msgWidget "❕Enter a valid string value❕"

        return
    fi
    
    typeset -i column_num=$column_index+1
    
    for record_num in "${record_nums[@]}";
    do
        typeset -i rec_num=$record_num+2
        awk -F"," -v record_number="$rec_num" -v column_number=$column_num -v new_value="$new_val" 'BEGIN { OFS="," } { if ( NR==record_number ) { $column_number=new_value; print $0 } else { print $0 } }' $1/$t > $1/.f.csv
        
        mv "$1"/.f.csv "$1"/"$t"
		msgWidget "✅ Update Column ($column) Done ✅"
    done
    
}

updateMainMenu "$1"