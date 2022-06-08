#!/bin/bash
# Black        0;30     Dark Gray     1;30
# Red          0;31     Light Red     1;31
# Green        0;32     Light Green   1;32
# Brown/Orange 0;33     Yellow        1;33
# Blue         0;34     Light Blue    1;34
# Purple       0;35     Light Purple  1;35
# Cyan         0;36     Light Cyan    1;36
# Light Gray   0;37     White         1;37

# RED='\033[0;31m'
Green='\033[1;32m'
Cyan='\033[1;36m'
NC='\033[0m' # No Color

title="$1"
topLine1="╔══════════════════ "
topLine2=" ══════════════════╗"

bottomLine1="╚══════════════════ "
bottomLine2=" ══════════════════╝"

echo -en "$Cyan$topLine1$NC"

for (( i=0; i<${#title}; i++ )); do
#   echo "${title:$i:1}"
        echo -n "╍" 
done 
echo -e "$Cyan$topLine2$NC"
for (( i=0; i<${#topLine1}; i++ )); do
 if [[ $i -eq 0 ]]
    then
        # echo -n "│"
        echo -en "$Cyan║$NC"
    else
        echo -n " "
    fi
done
echo  -en "$Green$title$NC"
for (( i=1; i<=${#topLine2}; i++ )); do
 if [[ $i -eq ${#topLine2} ]]
    then
        echo -e  "$Cyan║$NC"
    else
        echo -n " "
    fi
done
echo -en "$Cyan$bottomLine1$NC"
for (( i=0; i<${#title}; i++ )); do
    echo -n "╍"
done
echo -e "$Cyan$bottomLine2$NC"


