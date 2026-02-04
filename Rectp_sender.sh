#!/usr/bin/env bash

echo -e "\e[1;32mRECTP SENDER\e[0m: Wrapper del cliente de RECTP\n"

sleep 0.5

SERVER_ADDRESS=$1

if [ $# -lt 1 ]
then
	while [ "$SERVER_ADDRESS" == "" ]
	do
		read -p "Introduce la dirección del servidor: " SERVER_ADDRESS
		if [ "$SERVER_ADDRESS" == "" ]
		then
			echo -e "\e[0;30;41mIntroduce un nombre válido.\e[0m"
			sleep 0.5
		fi
	done
fi

MESSAGE=""

while [ "$MESSAGE" == "" ]
do
	read -p "Introduce el mensaje a enviar: " MESSAGE
	if [ "$MESSAGE" == "" ]
	then
		echo -e "\e[0;30;41mIntroduce un mensaje.\e[0m"
		sleep 0.5
	fi
done


echo -en "\n\e[1;36mGenerando el archivo de audio: \e[0m"

echo "$MESSAGE" | text2wave -o audio.wav

sleep 1
echo -e "\e[1;32mGENERADO\n\e[0m"

sleep 1
echo -en "\e[1;33mInciando el cliente de RECTP \e[0m"

sleep 1
echo -n "."

sleep 1
echo -n "."

sleep 1
echo -n "."

sleep 2

./cliente.sh $SERVER_ADDRESS

ERROR_RECTP=$?

if [ $ERROR_RECTP -gt 0 ]
then
	echo -e "\e[0;30;41mError $ERROR_RECTP al enviar el archivo.\e[0m"

	FECHA=`date`

	echo "$ERROR_RECTP $FECHA" >> rectp_sender.log
fi
