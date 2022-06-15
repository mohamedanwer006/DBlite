#!/bin/bash


PS3="Enter option number: "
dbDir="DATABASES"

dbName=$2

function index_of(){
    
    my_array="$2[@]"
    arr=("${!my_array}")
    value=$1
    for i in "${!arr[@]}"; do
        if [[ "${arr[$i]}" = "${value}" ]];
        then
            return "$i"
        fi
    done
}


function selectMainMenu(){
    
    PS3="Enter the number of the table you want to select from: "
    tables=($(ls "$dbDir/$dbName/")) #create array of table names as options
    declare -a args=(
        --title "Chose table to select from" --notags --fb --menu "Select table from below 👇" 20 60 "${#tables[@]}"
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
    whereMenu $dbDir/$dbName $t
    return 0
}


function whereMenu(){
    choices=("Yes" "No" )
    
    declare -a args=(
        --title "Select from $t" --notags --fb --menu "Will you be specifying where? 👇" 20 60 "${#choices[@]}"
    )
    # create array of menu commands
    for item in "${choices[@]}"; do
        args+=("$item" "$item")
    done
    choice=$(whiptail "${args[@]}" 3>&1 1>&2 2>&3 )
    if [[  $? == 1 ]]
    then
        return
    fi
    case $choice in
        "${choices[0]}") columnMenu "$1" "$t" 1 ;; #selectColumn $1 $t $col $col_no
        "${choices[1]}") columnMenu "$1" "$t" 0 ;;
    esac
    
}


function columnMenu(){
    # with out where clause
    if [[ $3 -eq 0 ]];
    then
        # echo "Select certain columns or Select * (All)?"
        declare -a selectOptions=("Choose column(s)" "* (All)" )
        # PS3="Enter option number: "
        
        declare -a args=(
            --title "Select column" --notags --fb --menu "Select certain columns or Select * (All)? 👇" 20 60 "${#selectOptions[@]}"
        )
        # create array of menu commands
        for item in "${selectOptions[@]}"; do
            args+=("$item" "$item")
        done
        so=$(whiptail "${args[@]}" 3>&1 1>&2 2>&3 )
        if [[  $? == 1 ]]
        then
            return
        fi
        
        if [[ $so == "* (All)" ]]; then
            awk 'NR!=2' "$1/$t" > .out.tmp
            whiptail --textbox .out.tmp 30 40 --fb --scrolltext
            rm .out.tmp 2>/dev/null
        fi
        
        if [[ $so == "Choose column(s)" ]]
        then
            IFS="," read -r -a columns < <(head -n 1 "$dbDir/$dbName/$t")

            declare -a args=(
                --title "SELECT column,s FROM $t  " --notags --fb --checklist "Select columns you want : 👇" 20 60 "${#columns[@]}"
            )
            # create array of menu commands
            for item in "${columns[@]}"; do
                args+=("$item" "$item" "off")
            done
            selectedCols=$(whiptail "${args[@]}" 3>&1 1>&2 2>&3 )
            if [[  $? == 1 ]]
            then
                return
            fi
            
            declare indexes=""
            flag=0
            for item in $selectedCols
            do
                # ignore first item
                if [[ $flag == 1 ]]
                then
                    indexes+=","
                fi
                
                item=$(echo "$item" | sed 's/^"//;s/"$//')
                
                index_of "$item" columns
                var=$?
                # echo "$var"
                indexes+=$(("$var"+1))
                flag=1
            done

            selectColumn $1 $t $indexes # or $col instead of $REPLY
            return
            
        fi
        return
    fi
    
    
    # here if user will select where
    declare -a selectOptions=("Choose column(s)" "* (All)")
    # PS3="Select certain columns or Select * (All)?"
    
    declare -a args=(
        --title "Select column where " --notags --fb --menu "Select certain columns or Select * (All)? 👇" 20 60 "${#selectOptions[@]}"
    )
    # create array of menu commands
    for item in "${selectOptions[@]}"; do
        args+=("$item" "$item")
    done
    so=$(whiptail "${args[@]}" 3>&1 1>&2 2>&3 )
    if [[  $? == 1 ]]
    then
        return
    fi
    
    
    if [[ $so == "Choose column(s)" ]]
    then
        IFS="," read -r -a columns < <(head -n 1 "$1/$t")
        
        
        declare -a args=(
            --title "SELECT column,s FROM $t  " --notags --fb --checklist "Select columns you want : 👇" 20 60 "${#columns[@]}"
        )
        # create array of menu commands
        for item in "${columns[@]}"; do
            args+=("$item" "$item" "off")
        done
        selectedCols=$(whiptail "${args[@]}" 3>&1 1>&2 2>&3 )
        if [[  $? == 1 ]]
        then
            return
        fi
        
        declare indexes=""
        flag=0
        for item in $selectedCols
        do
            # ignore first item
            if [[ $flag == 1 ]]
            then
                indexes+=","
            fi
            
            item=$(echo "$item" | sed 's/^"//;s/"$//')
            
            index_of "$item" columns
            var=$?
            # echo "$var"
            indexes+=$(("$var"+1))
            flag=1
        done
        selection=$indexes
        
        
        IFS="," read -r -a cond_columns < <(head -n 1 "$1"/"$t")
        
        declare -a args=(
            --title "Select column where " --notags --fb --menu "Select where column 👇" 20 60 "${#cond_columns[@]}"
        )
        # create array of menu commands
        for item in "${cond_columns[@]}"; do
            args+=("$item" "$item")
        done
        cond_column=$(whiptail "${args[@]}" 3>&1 1>&2 2>&3 )
        if [[  $? == 1 ]]
        then
            return
        fi
        
        typeset -i cond_column_index
        typeset -i cond_column_number
        
        index_of "$cond_column" cond_columns #get column index
        cond_column_index=$?
        
        criteria=$(whiptail --title "Select where column " --fb --inputbox "Enter search criteria/value for that column" 12 50 3>&1 1>&2 2>&3 )
        if [[ $? == 1  ]]
        then
            return
        fi
        # Now use table($1/$t), condition_column and its index to filter records, selection to cut fields/columns that were selected
        cond_column_number=$cond_column_index+1
        record_nums=( $(tail -n +3 $1/$t | cut -d, -f$cond_column_number | grep -n $criteria | cut -f1 -d:) )
        
        touch $1/$t.tmp
        cut -d, -f$selection $1/$t | sed -n "1p" > $1/$t.tmp
        
        for record_num in "${record_nums[@]}";
        do
            tail -n +3 $1/$t | cut -d, -f$selection | sed -n "${record_num}p" >> $1/$t.tmp # Remember to cut with $selection
        done
        
        whiptail --textbox "$1/$t.tmp" 30 40 --fb --scrolltext
        rm "$1/$t.tmp"
        return
        
    fi
    
    if [[ $so == "* (All)" ]]; then
        
        # PS3="Select the column for the where clause: "
        IFS="," read -r -a cond_columns < <(head -n 1 $1/$t)
        
        declare -a args=(
            --title "Select from $t where " --notags --fb --menu "Select the column for the where clause: 👇" 20 60 "${#cond_columns[@]}"
        )
        # create array of menu commands
        for item in "${cond_columns[@]}"; do
            args+=("$item" "$item")
        done
        cond_column=$(whiptail "${args[@]}" 3>&1 1>&2 2>&3 )
        if [[  $? == 1 ]]
        then
            return
        fi
        
        typeset -i cond_column_index
        typeset -i cond_column_number
        
        index_of "$cond_column" cond_columns #get column index
        cond_column_index=$?
        
        criteria=$(whiptail --title "Select from $t where"  --fb --inputbox "Enter search criteria/value for that column" 12 50 3>&1 1>&2 2>&3 )
        if [[ $? == 1  ]]
        then
            return
        fi
        # Now use table($1/$t), condition_column and its index to filter records, selection to cut fields/columns that were selected
        cond_column_number=$cond_column_index+1
        record_nums=( $(tail -n +3 $1/$t | cut -d, -f$cond_column_number | grep -n $criteria | cut -f1 -d:) )
        
        touch "$1"/"$t".tmp
        sed -n "1p" "$1"/"$t" > "$1"/"$t".tmp
        
        for record_num in "${record_nums[@]}";
        do
            tail -n +3 "$1"/"$t" | sed -n "${record_num}p" >> "$1"/"$t".tmp # Remember to cut with $selection
        done
        
        whiptail --textbox "$1/$t.tmp" 30 40 --fb --scrolltext
        rm "$1"/"$t".tmp
        
    fi
    
}


function selectColumn(){
    awk -F"," 'NR!=2' $1/$t > $1/$t.tmp
    cut -d"," -f$3 $1/$t.tmp > .out.tmp
    whiptail --textbox ".out.tmp" 30 40 --fb --scrolltext
    rm .out.tmp 2>/dev/null
    rm $1/$t.tmp
}


function selectWhere(){
    
    typeset -i cond_no=$cond_no+1
    typeset -i col_no=$col_no+1
    
    awk -F"," -v column="$col_no" -v condition="$cond_no" -v fltr="$filter" '{ if ( $condition=="$fltr" ) {  print $0 } else { next } }' $1/$t > "$1/buffer"
    
    whiptail --textbox "$1/buffer" 30 40 --fb --scrolltext
    
}

selectMainMenu "$1"