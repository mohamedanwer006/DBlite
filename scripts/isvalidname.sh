#!/bin/bash
#   check if the argument is a valid name starting with a letter and followed by letters, numbers, or underscores
#   return 0 if it is a valid name
#   return 1 if it is not a valid name
#   this script run as a  sourced script
#   to use it as a function . isvalidname.sh <name>


if [[  ! $1 =~ ^[a-zA-Z]+[a-zA-Z0-9_]*$  ]]
then
    return 1
else
    return 0
fi
