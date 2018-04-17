#!/bin/bash
echo "Dont' copy and paste in file as it screws up indentation"

echo -e "*** Make sure proper cipher is given ***"
sleep 2

pt_len="64"
key_len="32"
iv_len="64"
add_len="32"

iv=$(tr -c -d "0-9a-f" < /dev/urandom | head -c $iv_len)
key=$(tr -c -d "0-9a-f" < /dev/urandom | head -c $key_len)
pt=$(tr -c -d "0-9a-f" < /dev/urandom | head -c $pt_len)
assoc=$(tr -c -d "0-9a-f" < /dev/urandom | head -c $add_len)

#declare -a tag_len=("4" "8" "12" "13" "14" "15" "16")
#taglen=8

cipher="sha512"

#echo "IV : $iv"
#echo "Key : $key"
#echo "Plain : $pt"
#echo "Assoc : $assoc"
#echo "Tag len : $taglen"

#for (( i=1;i<=20;i++ ))
#{
#pt_len="12"
#key_len="128"
#iv_len="32"
#add_len="32"
#
#iv=$(tr -c -d "0-9a-f" < /dev/urandom | head -c $iv_len)
#key=$(tr -c -d "0-9a-f" < /dev/urandom | head -c $key_len)
#pt=$(tr -c -d "0-9a-f" < /dev/urandom | head -c $pt_len)
#assoc=$(tr -c -d "0-9a-f" < /dev/urandom | head -c $add_len)
#taglen=${tag_len["$[RANDOM % ${#tag_len[@]}]"]}

#echo "kcapi -e -x 1 -c \"$cipher\" -p $pt -k $key -i $iv"
#enc_data=$(kcapi -e -x 1 -c "$cipher" -p $pt -k $key)
#enc_data=$(kcapi -e -x 1 -c "$cipher" -p $pt -k $key -i $iv)
#enc_data=$(kcapi -e -x 2 -c "$cipher" -p $pt -k $key -i $iv -l $taglen -a $assoc)
#
#cut_tag=$((taglen*2))
#tag_data=$(echo -n $enc_data | tail -c $cut_tag)
#actual_enc=$(echo -n $enc_data | cut -c1-$pt_len)
##printf "\n       {    'cipher_type' : '2',
##            'plain_text' : '$pt',
##            'key' : '$key',
##            'iv' : '$iv',
##            'assosc_data' : '$assoc',
##            'tag_len' : '$taglen',
##            'result' : '$enc_data'\n " >> file.txt
##printf "      }," >> file.txt
##
##ct=$(kcapi -x 1 -c $cipher -q $enc_data -k $key)
ct=$(kcapi -x 1 -c $cipher -q $enc_data -k $key -i $iv)
echo -e "\n$ct"
###echo "kcapi -x 2 -c $cipher -q $actual_enc -k $key -i $iv -a $assoc -t $tag_data"
#ct=$(kcapi -x 2 -c $cipher -q $actual_enc -k $key -i $iv -a $assoc -t $tag_data)
###echo $ct
##
#printf "\n       {    'cipher_type' : '2',
#            'cipher_text' : '$actual_enc',
#            'key' : '$key',
#            'iv' : '$iv',
#            'assosc_data' : '$assoc',
#            'tag' : '$tag_data',
#            'result' : '$pt'\n " >> file.txt
#printf "      }," >> file.txt
#}
#assoc="261a9efd4f32bc3d07c115b4edcf8adf"
#key="a1b90cba3f06ac353b2c343876081762090923026e91771815f29dab01932f2f"
#tag_data="87fdf1261846164a950c37a3f2eea17d"
#iv="4faef7117cda59c66e4b92013e768ad5"
#actual_enc="778ae8b43cb98d5a825081d5be471c63"
#pt="ebabce95b14d3c8d6fb350390790311c"
hex_iv=$(/root/convert_to_hex.sh $iv)
hex_key=$(/root/convert_to_hex.sh $key)
hex_pt=$(/root/convert_to_hex.sh $pt)
#/root/convert_to_hex.sh $enc_data 
#hex_ct=$(/root/convert_to_hex.sh $actual_enc)
hex_ct=$(/root/convert_to_hex.sh $enc_data)
hex_aad=$(/root/convert_to_hex.sh $assoc)
hex_tag=$(/root/convert_to_hex.sh $tag_data)

#Vector Format
printf "\t{"
printf "\n\t.alg = FUN_CRYPTO_AES_CTS,"
printf "\n\t.op = FUN_CRYPTO_OP_ENCRYPT,"
printf "\n\t.phase = FUN_CRYPTO_PHASE_COMPLETE,"
printf "\n\t.ctxlen = 32,"
printf "\n\t.ptxlen = 32,"
printf "\n\t.keylen = 32,"
printf "\n\t.params.gcm.ivlen = 12,"
printf "\n\t.params.gcm.aadlen = 0,"
printf "\n\t.params.gcm.taglen = 16,"
printf "\n\t.key = {"
printf "\n\t\t$hex_key"
printf "\n\t\t},"
printf "\n"
printf "\n\t.params.gcm.iv = {"
printf "\n\t\t$hex_iv"
printf "\n\t\t},"
printf "\n"
printf "\n\t.params.gcm.aad = {"
printf "\n\t\t$hex_aad"
printf "\n\t\t},"
printf "\n"
printf "\n\t.params.gcm.tag = {"
printf "\n\t\t$hex_tag"
printf "\n\t\t},"
printf "\n"
printf "\n\t.ptx = {"
printf "\n\t\t$hex_pt"
printf "\n\t\t},"
printf "\n"
printf "\n\t.ctx = {"
printf "\n\t\t$hex_ct"
printf "\n\t\t},"
printf "\n\t},\n"
