#!/bin/bash

echo
echo

IS_PROD_ENV=false
ENV="beta"

if [[ "$2" == "prod" ]]; then
	ENV="prod"
	IS_PROD_ENV=true
fi

if [[ "$1" ]]; then
	echo "generating $ENV token for $1 . . ."
	cd ~/dev/credentials-service

	if [ "$IS_PROD_ENV" = true ]; then
		go run . token -t $1 -p
	else
		go run . token -t $1
	fi
else
	echo
	echo "USAGE:"
	echo "\prodtoken <TENANT ID>"
fi

echo
echo
