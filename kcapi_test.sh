#!/bin/bash

echo -e "*** Make sure proper cipher is given ***"
sleep 2

pt_len="640"
key_len="32"
iv_len="32"
add_len="32"

iv=$(tr -c -d "0-9a-f" < /dev/urandom | head -c $iv_len)
key=$(tr -c -d "0-9a-f" < /dev/urandom | head -c $key_len)
pt=$(tr -c -d "0-9a-f" < /dev/urandom | head -c $pt_len)
assoc=$(tr -c -d "0-9a-f" < /dev/urandom | head -c $add_len)

declare -a tag_len=("4" "8" "12" "13" "14" "15" "16")
#taglen=8

cipher="gcm(aes)"

#echo "IV : $iv"
#echo "Key : $key"
#echo "Plain : $pt"
#echo "Assoc : $assoc"
#echo "Tag len : $taglen"

for (( i=1;i<=20;i++ ))
{
pt_len="640"
pt_len=$((pt_len*i)) 
echo "Encrypted,$pt_len"
key_len="32"
iv_len="32"
add_len="32"

iv=$(tr -c -d "0-9a-f" < /dev/urandom | head -c $iv_len)
key=$(tr -c -d "0-9a-f" < /dev/urandom | head -c $key_len)
pt=$(tr -c -d "0-9a-f" < /dev/urandom | head -c $pt_len)
assoc=$(tr -c -d "0-9a-f" < /dev/urandom | head -c $add_len)
taglen=${tag_len["$[RANDOM % ${#tag_len[@]}]"]}
#echo "kcapi -e -x 1 -c \"$cipher\" -p $pt -k $key -i $iv"
#enc_data=$(kcapi -e -x 1 -c "$cipher" -p $pt -k $key)
#enc_data=$(kcapi -e -x 1 -c "$cipher" -p $pt -k $key -i $iv)
enc_data=$(kcapi -e -x 2 -c "$cipher" -p $pt -k $key -i $iv -l $taglen -a $assoc)

cut_tag=$((taglen*2))
tag_data=$(echo -n $enc_data | tail -c $cut_tag)
actual_enc=$(echo -n $enc_data | cut -c1-$pt_len)
#printf "\n       {    'cipher_type' : '2',
#            'plain_text' : '$pt',
#            'key' : '$key',
#            'iv' : '$iv',
#            'assosc_data' : '$assoc',
#            'tag_len' : '$taglen',
#            'result' : '$enc_data'\n " >> file.txt
#printf "      }," >> file.txt
#
#ct=$(kcapi -x 1 -c $cipher -q $enc_data -k $key)
#ct=$(kcapi -x 1 -c $cipher -q $enc_data -k $key -i $iv)
##echo "kcapi -x 2 -c $cipher -q $actual_enc -k $key -i $iv -a $assoc -t $tag_data"
ct=$(kcapi -x 2 -c $cipher -q $actual_enc -k $key -i $iv -a $assoc -t $tag_data)
##echo $ct
#
printf "\n       {    'cipher_type' : '2',
            'cipher_text' : '$actual_enc',
            'key' : '$key',
            'iv' : '$iv',
            'assosc_data' : '$assoc',
            'tag' : '$tag_data',
            'result' : '$pt'\n " >> file.txt
printf "      }," >> file.txt
}
#hex_iv=$(sh convert_to_hex.sh $iv)
#hex_key=$(sh convert_to_hex.sh $key)
#hex_pt=$(sh convert_to_hex.sh $pt)
##sh convert_to_hex.sh $enc_data 
#hex_ct=$(sh convert_to_hex.sh $actual_enc)
#hex_add=$(sh convert_to_hex.sh $assoc)
#hex_tag=$(sh convert_to_hex.sh $tag_data)
#
#Vector Format
#printf "        {
#        .alg = FUN_CRYPTO_AES_GCM,
#        .op = FUN_CRYPTO_OP_ENCRYPT,
#        .phase = FUN_CRYPTO_PHASE_COMPLETE,
#        .ctxlen = $((pt_len/2)),
#        .ptxlen = $((pt_len/2)),
#        .keylen = $((key_len/2)),
#        .params.gcm.ivlen = $((iv_len/2)),
#        .params.gcm.aadlen = $((add_len/2)),
#        .params.gcm.taglen = $taglen,
#        .key =  { 
#		$hex_key
#                },
#
#        .params.gcm.iv = {
#		$hex_iv
#                },
#
#        .params.gcm.aad = {
#		$hex_add
#                },
#
#        .params.gcm.tag = {
#		$hex_tag
#                },
#
#        .ptx =  {
#		$hex_pt
#                },
#
#        .ctx =  {
#		$hex_ct
#                },
#        },\n"
