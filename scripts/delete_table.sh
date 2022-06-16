#!/bin/bash

function msgWidget(){
    whiptail --msgbox  --fb "$1" 12 50
}


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


function deleteMainMenu(){

    tables=($(ls "$1")) #create array of table names as options
    
    declare -a args=(
        --title "DELETE FROM table" --notags --fb --menu "Select table from below  you want to delete in👇" 20 60 "${#tables[@]}"
    )
    # create array of menu commands
    for item in "${tables[@]}"; do
        args+=("$item" "$item")
    done
    t=$(whiptail "${args[@]}" 3>&1 1>&2 2>&3 )
    
    if [[ $? == 1  ]]
    then
        return 0
    fi

    deleteTableMenu "$1" "$t"

}


function deleteTableMenu(){
    deleteOptions=("Yes -> Choose column" "No -> TRUNCATE")

    declare -a args=(
        --title "Delete in table ($t )" --notags --fb --menu "Will you be specifying where? " 20 60 "${#deleteOptions[@]}"
    )
    # create array of menu commands
    for item in "${deleteOptions[@]}"; do
        args+=("$item" "$item")
    done
    deleteOption=$(whiptail "${args[@]}" 3>&1 1>&2 2>&3 )
    
    if [[ $? == 1  ]]
    then
        return 0
    fi
    
    if [[ $deleteOption == "Yes -> Choose column" ]]
    then
        IFS="," read -r -a cond_columns < <(head -n 1 "$1/$t")

        
        declare -a args=(
            --title "Delete in table ($t )" --notags --fb --menu "Select from below 👇 " 20 60 "${#cond_columns[@]}"
        )
        # create array of menu commands
        for item in "${cond_columns[@]}"; do
            args+=("$item" "$item")
        done
        cond_column=$(whiptail "${args[@]}" 3>&1 1>&2 2>&3 )
        
        if [[ $? == 1  ]]
        then
            return 0
        fi

        typeset -i cond_column_index
        typeset -i cond_column_number
        
        index_of "$cond_column" cond_columns #get column index
        cond_column_index=$?

        criteria=$(whiptail --title "DELETE INTO $1 " --ok-button "OK"  --fb --inputbox "Enter value for that column: ( $cond_column )" 12 50 3>&1 1>&2 2>&3 )
        if [[ $? == 1 ]]
        then
            return
        fi
        

        cond_column_number=$cond_column_index+1
        record_nums=( $(tail -n +3 "$1/$t" | cut -d, -f"$cond_column_number" | grep -n -v ^"$criteria"$ | cut -f1 -d:) )
        
        touch "$1/$t.tmp"

        sed -n "1,2p" "$1/$t" > "$1/$t.tmp"
        
        for record_num in "${record_nums[@]}";
        do
            tail -n +3 "$1/$t" | sed -n "${record_num}p" >> "$1/$t.tmp"
        done
        
       	 mv "$1/$t.tmp" "$1/$t"

		 msgWidget "❌ The value has been deleted from $t ❌"
        return
        # done
    fi
    
    if [[ $deleteOption == "No -> TRUNCATE" ]];
    then
        sed -i '3,$d' "$1/$t"
    fi
     msgWidget "❌ The $t is TRUNCATED  ❌"
    return

}

deleteMainMenu "$1"
