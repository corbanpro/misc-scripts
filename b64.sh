#!/bin/bash

if [ $1 == "-e" ]; then
	echo $2 | base64
	echo
elif [ $1 == "-d" ]; then
	echo $2 | base64 --decode
	echo
else
	echo $1 | base64 --decode
	echo
fi
