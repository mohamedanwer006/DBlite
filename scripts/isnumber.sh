#!/bin/bash
#   check if the argument is a digit number
#   return 0 if it is a digit number
#   return 1 if it is not a digit number
#   this script run as a  sourced script
#   to use it as a function . isnumber.sh <arg 

if [[ $1 = *([0-9]) ]]
then
    return 0
else
    return 1
fi



