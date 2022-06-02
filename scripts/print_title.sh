#!/bin/bash

title="$1"
topLine1="╔══════════════════ "
topLine2=" ══════════════════╗"

bottomLine1="╚══════════════════ "
bottomLine2=" ══════════════════╝"

echo -n "$topLine1"

for (( i=0; i<${#title}; i++ )); do
#   echo "${title:$i:1}"
        echo -n "╍" 
done 
echo "$topLine2"
for (( i=0; i<${#topLine1}; i++ )); do
 if [[ $i -eq 0 ]]
    then
        # echo -n "│"
        echo -n "║"
    else
        echo -n " "
    fi
done
echo  -n "$title"
for (( i=1; i<=${#topLine2}; i++ )); do
 if [[ $i -eq ${#topLine2} ]]
    then
        echo   "║"
    else
        echo -n " "
    fi
done
echo -n "$bottomLine1"
for (( i=0; i<${#title}; i++ )); do
    echo -n "╍"
done
echo "$bottomLine2"


