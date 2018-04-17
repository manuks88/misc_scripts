#!/bin/bash

echo -e "*** Make sure proper cipher is given ***"
sleep 2

key_size="32"

printf "{\n" > file.txt
printf "   'enc_cbc(aes)':[" >> file.txt
printf "\n" >> file.txt
for i in {1..640}
do
{
	if (( ($i % 32) == 0 ))
	then
	{
		pt=$(tr -c -d "0-9a-f" < /dev/urandom | head -c $i)
		iv_size=$(( RANDOM % 100 ))
		if [ $iv_size != 0 ]
		then
		{
			iv=$(tr -c -d "0-9a-f" < /dev/urandom | head -c $iv_size)
		}
		else
		{
			iv="\"\""
		}
		fi
		key=$(tr -c -d "0-9a-f" < /dev/urandom | head -c $key_size)
		enc_data=$(kcapi -e -x 1 -c "cbc(aes)" -p $pt -k $key -i $iv)
		printf "\n      {   'cipher_type' : '1',
          'plain_text' : '$pt',
          'key' : '$key',
          'iv' : '$iv',
          'result' : '$enc_data'\n" >> file.txt
		printf "      }," >> file.txt
	}
	fi
}
done
printf "\n   ],\n" >> file.txt
printf "\n   'dec_cbc(aes)':[" >> file.txt
printf "\n" >> file.txt
for i in {1..640}
do
{
	if (( ($i % 32) == 0 ))
	then
	{
		pt=$(tr -c -d "0-9a-f" < /dev/urandom | head -c $i)
		iv_size=$(( RANDOM % 100 ))
		if [ $iv_size != 0 ]
		then
		{
			iv=$(tr -c -d "0-9a-f" < /dev/urandom | head -c $iv_size)
		}
		else
		{
			iv="\"\""
		}
		fi
		key=$(tr -c -d "0-9a-f" < /dev/urandom | head -c $key_size)
		enc_data=$(kcapi -e -x 1 -c "cbc(aes)" -p $pt -k $key -i $iv)
		printf "\n      {   'cipher_type' : '1',
		'cipher_text' : '$enc_data',
		'key' : '$key',
		'iv' : '$iv',
		'result' : '$pt'\n" >> file.txt
		printf "      }," >> file.txt
	}
	fi
}
done
printf "\n   ]\n" >> file.txt
printf "}" >> file.txt
