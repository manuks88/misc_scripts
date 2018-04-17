#!/bin/bash

if [ $# -lt 1 ]
then
{
        echo "Provide file name."
        exit 1
}
fi

file_name=$1

if [ -f $file_name ]
then
{
        #Encryption File
        rand_file1=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 4 | head -n 1)
        sed -n '/\[L/,//p' $file_name > /tmp/$rand_file1
        rand_file2=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 4 | head -n 1)
        sed -e '/\[L/d' /tmp/$rand_file1 > /tmp/$rand_file2
#        echo "Encryption file is $rand_file2"
	count=$(cat /tmp/$rand_file2 |sed -n -e 's/^.*Len = //p')
#        printf "{\n    'dgst_sha384':[\n" > file.txt
	for i in $count
        {
                rm -rf /tmp/Vectors
                grep -w "Len = $i" /tmp/$rand_file2 -A 3 | sed 's/\s//g' > /tmp/Vectors
                msg=$(grep 'Msg=' /tmp/Vectors | cut -d=  -f2)
                md=$(grep 'MD=' /tmp/Vectors | cut -d= -f2)
                printf "\n      {    'cipher_type' : '3',
           'MSG' : '$msg',
           'MD' : '$md'\n" >> file.txt
               printf "      }," >> file.txt
        }
	rm -rf /tmp/$rand_file1 /tmp/$rand_file2 /tmp/Vectors
}
else
{
	echo "File not found"
}
fi
