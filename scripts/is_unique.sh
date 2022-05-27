#!/bin/bash

# $1 is value, $2 is column/field number, $3 is table name

if sed -n '4,$ p' $3 | cut -d, -f$2 | grep -Eo "^$1$" > /dev/null ;
then
	echo "Value already exists in column."
	return 1
fi

return 0 #If unique value is passed to this script