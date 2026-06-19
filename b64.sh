#!/bin/bash

if [ $1 == "-e" ]; then
	echo $2 | base64
elif [ $1 == "-d" ]; then
	echo $2 | base64 --decode
else
	echo $1 | base64 --decode
fi
