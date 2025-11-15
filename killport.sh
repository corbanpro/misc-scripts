#!/bin/bash

if [ -z $1 ]; then
	argerr killport
	echo "USAGE: killport <port_number>"
	exit 1
fi

pid=$(lsof -ti :$1 -sTCP:LISTEN)
if [ -n "$pid" ]; then
	kill -9 $pid
	echo "Killed process $pid on port $1"
else
	echo "No process found on port $1"
fi
