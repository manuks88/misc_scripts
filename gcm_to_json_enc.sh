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
		sed -e '/\[Keylen/d' -e '/#/d' -e '/\[Keylen/d' -e '/\[IVlen/d' -e '/\[PTlen/d' -e '/\[AADlen/d' -e '/\[Taglen/d' $fname > /tmp/$rand_file1
	}
	rand_file2=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 4 | head -n 1)
#	awk 'BEGIN {c=0}/Count/{ gsub(/Count/,"Count = "c) ; c++;print ; next}{print}' /tmp/$rand_file1
	awk 'BEGIN {c=0}/Count/{ gsub(/Count.*$/,"Count = "c) ; c++;print ; next}{print}' /tmp/$rand_file1 > /tmp/$rand_file2

	count=$(cat /tmp/$rand_file1 | grep -i Count | wc -l)
	printf "{\n    'enc_gcm(aes)':[\n" > file.txt
	for (( i=0;i<$count;i++ ))
	{
		grep -w "Count = $i" /tmp/$rand_file2 -A 6 | sed 's/\s//g' > /tmp/Vectors
		key=$(grep 'Key=' /tmp/Vectors | cut -d=  -f2)
		iv=$(grep 'IV=' /tmp/Vectors | cut -d= -f2)
		aad=$(grep 'AAD=' /tmp/Vectors | cut -d= -f2)
		tag=$(grep 'Tag=' /tmp/Vectors | cut -d= -f2)
		plain=$(grep 'PT=' /tmp/Vectors | cut -d= -f2)
		cipher=$(grep 'CT=' /tmp/Vectors | cut -d= -f2)
		ebad=$(grep 'FAIL' /tmp/Vectors)
		tag_len_total=$(echo -n $tag | wc -m)
		tag_len=$((tag_len_total/2))
		if [ -z "$key" ]
		then
			key='""'
		elif [ -z "$iv" ]
		then
			iv='""'
		elif [ -z "$aad" ]
		then
			aad='""'
		elif [ -z "$tag" ]
		then
			tag='""'
		elif [ -z "$plain" ]
		then
			plain='""'
		elif [ -z "$cipher" ]
		then
			cipher='""'
		fi
		
		if [ -z "$ebad" ]
		then
			:
		else
			plain="EBADMSG"
		fi
		
		printf "\n       {    'cipher_type' : '2',
            'plain_text' : '$plain',
            'key' : '$key',
            'iv' : '$iv',
            'assosc_data' : '$aad',
            'tag' : '$tag',
	    'tag_len' : '$tag_len',
            'result' : '$cipher'\n " >> file.txt
               printf "      }," >> file.txt
	}
	printf "\n    ],\n" >> file.txt
	rm -rf /tmp/$rand_file1
	#Decryption File
#	for fname in "${file_names[@]}"
#        {
#                sed -n '/DECRYPT/,//p' $fname > /tmp/$rand_file1
#        }
#	sed -e '/ENCRYPT/d' -e '/DECRYPT/d' /tmp/$rand_file1 > /tmp/$rand_file2
#	count=$(cat /tmp/$rand_file2 | grep -i COUNT | wc -l)
#        printf "\n    'dec_ecb(aes)':[\n" >> file.txt
#        for (( i=0;i<$count;i++ ))
#        {       
#                grep "COUNT = $i" /tmp/$rand_file2 -A 4 | sed 's/\s//g' > /tmp/Vectors
#                key=$(grep 'KEY=' /tmp/Vectors | cut -d=  -f2)
#                iv=$(grep 'IV=' /tmp/Vectors | cut -d= -f2)
#                plain=$(grep 'PLAINTEXT=' /tmp/Vectors | cut -d= -f2)
#                cipher=$(grep 'CIPHERTEXT=' /tmp/Vectors | cut -d= -f2)
#                printf "\n       {    'cipher_type' : '1',
#            'cipher_text' : '$cipher',
#            'key' : '$key',
#            'iv' : '$iv',
#            'result' : '$plain'\n " >> file.txt
#               printf "      }," >> file.txt
#        }
#        printf "\n    ]" >> file.txt
#	printf "\n}" >> file.txt
}
else
{
	echo "File not found"
}
fi
