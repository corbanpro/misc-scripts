#!/bin/bash

echo
echo

IS_PROD_ENV=false
IS_NERVE_ENV=false
ENV="beta"

if [[ "$2" == "prod" ]]; then
	ENV="prod"
	IS_PROD_ENV=true
fi

if [[ "$2" == "nerve" ]]; then
	ENV="nerve"
	IS_NERVE_ENV=true
fi

if [[ "$1" ]]; then
	echo "generating $ENV token for $1 . . ."
	cd ~/dev/credentials-service

	if [ "$IS_PROD_ENV" = true ]; then
		go run . token -t $1 -p
	elif [ "$IS_NERVE_ENV" = true ]; then
		go run . token -t $1 -n
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
