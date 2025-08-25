#!/bin/bash

pid=$(lsof -ti :$1 -sTCP:LISTEN)
if [ -n "$pid" ]; then
	kill -9 $pid
	echo "Killed process $pid on port $1"
else
	echo "No process found on port $1"
fi
