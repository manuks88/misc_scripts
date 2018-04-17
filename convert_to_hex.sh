#!/bin/bash

input=$1

#echo $input | sed 's/.\{2\}/&,0x/g' | sed 's/^/0x/' | sed 's/.\{40\}/&\n/g' | sed 's/,/, /g'

var1=$(echo $input | sed 's/.\{2\}/&,0x/g' | sed 's/^/0x/' | sed 's/,/, /g')
var2=${var1::-2}
#echo $var2 | sed 's/^\(.\{47\}\).\(.*\)/\1\2/g'
#echo $var2 
echo $var2 | sed 's/.\{48\}/&\n/g' | sed 's/^\(.\{47\}\).\(.*\)/\1\2/g'
