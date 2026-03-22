#!/bin/bash

AUDIO_FILE="audio.wav"

VERSION_CURRENT="0.9"

PORT="9999"
IP_SERVER="localhost"

clear

echo "RECTP v$VERSION_CURRENT Client"

echo "1. SEND. Sending header to server"

IP_LOCAL=`ip -4 addr | grep "scope global" | awk '{print $2}' | cut -d "/" -f 1`

sleep 1

IP_LOCAL_HASH=`echo "$IP_LOCAL" | md5sum - | cut -d " " -f 1`

echo "RECTP $VERSION_CURRENT $IP_LOCAL $IP_LOCAL_HASH" | nc $IP_SERVER -q 0 $PORT

RESPONSE=`nc -l -p $PORT`

echo "2. TEST. Header Response"

if [ "$RESPONSE" != "HEADER_OK" ]
then
	echo "Error 1: Incorrect header"

	exit 1
fi

echo "3. SSEND. FILE NAME"

FILE_NAME_HASH=`echo "$AUDIO_FILE" | md5sum - | cut -d " " -f 1`

sleep 1
echo "FILE_NAME $AUDIO_FILE $FILE_NAME_HASH" | nc $IP_SERVER -q 0 $PORT

echo "3. LISTEN. FILE_NAME_OK"

RESPONSE=`nc -l -p $PORT`

echo "4. TEST. FILE_NAME_OK"

if [ "$RESPONSE" != "FILE_NAME_OK" ]
then
	echo "Error 2: Incorrect file name"
	exit 2
fi

echo "5.. SEND. FILE DATA"

sleep 1

cat audio.wav | nc $IP_SERVER -q 0  $PORT

echo "6. TEST FILE DATA OK"

RESPONSE=`nc -l -p $PORT`

if [ "$RESPONSE" != "FILE_DATA_OK" ]
then
	echo "ERROR 3: File data has been corrupted"

	exit 3
fi


echo "7.SEND. FILE CONTENT HASH"

FILE_CONTENT_HASH=`md5sum audio.wav | cut -d " " -f 1`

sleep 1

echo "$FILE_CONTENT_HASH" | nc $IP_SERVER -q 0  $PORT

RESPONSE=`nc -l -p $PORT `

echo "8.TEST  - FILE HASH OK"

if [ "$RESPONSE" == "FILE_HASH_KO" ]
then 
	echo "Error : problem in file content received by server"

fi

echo "End of comunication"

exit 0
