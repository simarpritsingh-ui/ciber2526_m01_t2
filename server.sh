#/bin/bash

VERSION_CURRENT="0.9"

PORT="9999"
IP_CLIENT="localhost"
SERVER_DIR="server"

clear

mkdir -p $SERVER_DIR

echo "Servidor de RECTP v$VERSION_CURRENT"

IP_LOCAL=`ip -4 addr | grep "scope global" | awk '{print $2}' | cut -d "/" -f 1`

echo "IP Local: $IP_LOCAL"

echo "0. LISTEN. HEADER"

DATA=`nc -l -p $PORT`

echo "3.1. TEST. Datos"

HEADER=`echo $DATA | cut -d " " -f 1`

if [ "$HEADER" != "RECTP" ]
then
	echo "ERROR 1: Cabecera errónea"

	sleep 1
	echo "HEADER_KO" | nc $IP_CLIENT -q 0 $PORT

	exit 1
fi

VERSION=`echo $DATA | cut -d " " -f 2`

if [ "$VERSION" != "$VERSION_CURRENT" ]
then
	echo "ERROR 2: Versión errónea"

	sleep 1
	echo "HEADER_KO" | nc $IP_CLIENT -q 0 $PORT

	exit 2
fi

IP_CLIENT=`echo $DATA | cut -d " " -f 3`

if [ "$IP_CLIENT" == "" ]
then
	echo "Error 4: IP de cliente mal formada ($IP_CLIENT)"

fi

IP_CLIENT_HASH=`echo $DATA | cut -d " " -f 4`
 
IP_CLIENT_HASH_TEST=`echo "$IP_CLIENT" | md5sum | cut -d " " -f 1`
 
 if [ "$IP_CLIENT_HASH" != "$IP_CLIENT_HASH_TEST" ]
 
  then
 
     echo "Error 5: IP de cliente mal formada (wrong hash)"
     exit 5
  fi


echo "3.2. RESPONSE. Enviando HEADER_OK"

sleep 1
echo "HEADER_OK" | nc $IP_CLIENT -q 0 $PORT

echo "4. LISTEN. Nombre de archivo"


DATA=`nc -l -p $PORT`
echo "8. FILE NAME"

echo "8.1 TEST"

FILE_NAME_PREFIX=`echo $DATA | cut -d " " -f 1`

if [ "$FILE_NAME_PREFIX" != "FILE_NAME" ]
then
	echo "Error 3: Prefijo FILE_NAME incorrecto ($FILE_NAME_PREFIX)"

	sleep 1
	echo "FILE_NAME_KO" | nc $IP_CLIENT -q 0 $PORT

	exit 3
fi


FILE_NAME=`echo $DATA | cut -d " " -f 2`

echo "File Name: $FILE_NAME"

FILE_NAME_HASH=`echo $DATA | cut -d " " -f 3`

FILE_NAME_HASH_TEST=`echo "$FILE_NAME" | md5sum | cut -d " " -f 1`
 
  if [ "$FILE_NAME_HASH" != "$FILE_NAME_HASH_TEST" ]
 
    then
 
      echo "Error 6: error in file name (wrong hash)"
      exit 6
fi

echo "8.2 RESPONSE FILE_NAME_OK"

sleep 1
echo "FILE_NAME_OK" | nc $IP_CLIENT -q 0 $PORT

echo "9. LISTEN FILE DATA"
echo "13. STORE FILE DATA"

nc -l -p $PORT > $SERVER_DIR/$FILE_NAME

echo "14. SEND. FILE_DATA_OK"

sleep 1
echo "FILE_DATA_OK" | nc $IP_CLIENT -q 0 $PORT

echo "TESTING FILE CONTENT"

FILE_PATH="$SERVER_DIR/$FILE_NAME"

FILE_PATH_HASH=`md5sum "$FILE_PATH" | cut -d " " -f 1`


echo "$FILE_PATH_HASH"

echo "SEND FILE_HASH_OK"
sleep 1

FILE_HASH_RECIVED=`nc -l -p  $PORT`

if [ "$FILE_HASH_RECIVED" != "$FILE_PATH_HASH"  ]
then

	echo "Error 7: problem in hash recived from client"
	echo "FILE_CONTENT_KO" | nc $IP_CLIENT -q 0 $PORT

else
	echo "FILE_CONTENT_OK" | nc $IP_CLIENT -q 0 $PORT

fi


aplay $SERVER_DIR/$FILE_NAME
echo "Fin de comunicación"
exit 0
