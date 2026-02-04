#/bin/bash

VERSION_CURRENT="0.9"

PORT="9999"
IP_CLIENT="localhost"
SERVER_DIR="server"

clear

mkdir -p $SERVER_DIR

echo "RECTP v$VERSION_CURRENT SERVER"

IP_LOCAL=`ip -4 addr | grep "scope global" | awk '{print $2}' | cut -d "/" -f 1`

echo "IP Local: $IP_LOCAL"

echo "0. LISTEN. HEADER"

DATA=`nc -l -p $PORT`

echo "1. TEST. DATA"

HEADER=`echo $DATA | cut -d " " -f 1`

if [ "$HEADER" != "RECTP" ]
then
	echo "ERROR 1: WRONG HEADER"

	sleep 1
	echo "HEADER_KO" | nc $IP_CLIENT -q 0 $PORT

	exit 1
fi

VERSION=`echo $DATA | cut -d " " -f 2`

if [ "$VERSION" != "$VERSION_CURRENT" ]
then
	echo "ERROR 2: WRONG VERSION"

	sleep 1
	echo "HEADER_KO" | nc $IP_CLIENT -q 0 $PORT

	exit 2
fi

IP_CLIENT=`echo $DATA | cut -d " " -f 3`

if [ "$IP_CLIENT" == "" ]
then
	echo "Error 3: PROBLEM IN CLIENT IP ($IP_CLIENT)"

fi

IP_CLIENT_HASH=`echo $DATA | cut -d " " -f 4`
 
IP_CLIENT_HASH_TEST=`echo "$IP_CLIENT" | md5sum | cut -d " " -f 1`
 
 if [ "$IP_CLIENT_HASH" != "$IP_CLIENT_HASH_TEST" ]
 
  then
 
     echo "Error 4: PROBLEM IN CLIENT IP (wrong hash)"
     exit 5
  fi


echo "3.2. RESPONSE. Enviando HEADER_OK"

sleep 1
echo "HEADER_OK" | nc $IP_CLIENT -q 0 $PORT

echo "5. LISTEN. Nombre de archivo"


DATA=`nc -l -p $PORT`
echo "6. FILE NAME"

echo "7. TEST"

FILE_NAME_PREFIX=`echo $DATA | cut -d " " -f 1`

if [ "$FILE_NAME_PREFIX" != "FILE_NAME" ]
then
	echo "Error 3: INCORRECT FILE_NAME PREFIX  ($FILE_NAME_PREFIX)"

	sleep 1
	echo "FILE_NAME_KO" | nc $IP_CLIENT -q 0 $PORT

	exit 3
fi


FILE_NAME=`echo $DATA | cut -d " " -f 2`

echo "8.FILE NAME: $FILE_NAME"

FILE_NAME_HASH=`echo $DATA | cut -d " " -f 3`

FILE_NAME_HASH_TEST=`echo "$FILE_NAME" | md5sum | cut -d " " -f 1`
 
  if [ "$FILE_NAME_HASH" != "$FILE_NAME_HASH_TEST" ]
 
    then
 
      echo "Error 6: ERROR IN FILE NAME RECIEVED (wrong hash)"
      exit 6
fi

echo "8.2 RESPONSE FILE_NAME_OK"

sleep 1
echo "FILE_NAME_OK" | nc $IP_CLIENT -q 0 $PORT

echo "9. LISTEN FILE DATA"

echo "10. STORE FILE DATA"

nc -l -p $PORT > $SERVER_DIR/$FILE_NAME

echo "11. SEND. FILE_DATA_OK"

sleep 1
echo "FILE_DATA_OK" | nc $IP_CLIENT -q 0 $PORT

echo "TESTING FILE CONTENT"

FILE_PATH="$SERVER_DIR/$FILE_NAME"

FILE_PATH_HASH=`md5sum "$FILE_PATH" | cut -d " " -f 1`


echo "$FILE_PATH_HASH"

echo "SEND FILE_HASH_OK"
sleep 1

FILE_HASH_RECEIVED=`nc -l -p  $PORT`

if [ "$FILE_HASH_RECEIVED" != "$FILE_PATH_HASH"  ]
then
	echo "Error 7: problem in hash received from client"

	echo "FILE_CONTENT_KO" | nc $IP_CLIENT -q 0 $PORT
else

do
	echo "FILE_CONTENT_KO" | nc -w 1 $IP_CLIENT -q 0 $PORT

done
fi


aplay $SERVER_DIR/$FILE_NAME
echo "End of comunication"
exit 0
