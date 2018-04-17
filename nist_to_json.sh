#!/bin/bash

if [ $# -lt 1 ]
then
{
	echo "Provide file name."
	exit 1
}
else
{
	file_names=( "$@" )
}
fi

#file_name=$1

if [ -f $file_name ]
then
{
	#Encryption File
	rand_file1=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 4 | head -n 1)
	for fname in "${file_names[@]}"
	{
		sed -n '/ENCRYPT/,/DECRYPT/p' $fname > /tmp/$rand_file1
	}
	rand_file2=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 4 | head -n 1)
	sed -e '/ENCRYPT/d' -e '/DECRYPT/d' /tmp/$rand_file1 > /tmp/$rand_file2
	echo "Encryption file is $rand_file2"
	count=$(cat /tmp/$rand_file2 | grep -i COUNT | wc -l)
	printf "{\n    'enc_ecb(aes)':[\n" > file.txt
	for (( i=0;i<$count;i++ ))
	{
		grep -w "COUNT = $i" /tmp/$rand_file2 -A 4 | sed 's/\s//g' > /tmp/Vectors
		key=$(grep 'KEY=' /tmp/Vectors | cut -d=  -f2)
		iv=$(grep 'IV=' /tmp/Vectors | cut -d= -f2)
		plain=$(grep 'PLAINTEXT=' /tmp/Vectors | cut -d= -f2)
		cipher=$(grep 'CIPHERTEXT=' /tmp/Vectors | cut -d= -f2)
		printf "\n       {    'cipher_type' : '1',
            'plain_text' : '$plain',
            'key' : '$key',
            'iv' : '$iv',
            'result' : '$cipher'\n " >> file.txt
               printf "      }," >> file.txt
	}
	printf "\n    ],\n" >> file.txt

	#Decryption File
	for fname in "${file_names[@]}"
        {
                sed -n '/DECRYPT/,//p' $fname > /tmp/$rand_file1
        }
	sed -e '/ENCRYPT/d' -e '/DECRYPT/d' /tmp/$rand_file1 > /tmp/$rand_file2
	count=$(cat /tmp/$rand_file2 | grep -i COUNT | wc -l)
        printf "\n    'dec_ecb(aes)':[\n" >> file.txt
        for (( i=0;i<$count;i++ ))
        {       
                grep "COUNT = $i" /tmp/$rand_file2 -A 4 | sed 's/\s//g' > /tmp/Vectors
                key=$(grep 'KEY=' /tmp/Vectors | cut -d=  -f2)
                iv=$(grep 'IV=' /tmp/Vectors | cut -d= -f2)
                plain=$(grep 'PLAINTEXT=' /tmp/Vectors | cut -d= -f2)
                cipher=$(grep 'CIPHERTEXT=' /tmp/Vectors | cut -d= -f2)
                printf "\n       {    'cipher_type' : '1',
            'cipher_text' : '$cipher',
            'key' : '$key',
            'iv' : '$iv',
            'result' : '$plain'\n " >> file.txt
               printf "      }," >> file.txt
        }
        printf "\n    ]" >> file.txt
	printf "\n}" >> file.txt
}
else
{
	echo "File not found"
}
fi
