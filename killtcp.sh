#!/bin/bash

for pid in $(lsof -nP -iTCP -sTCP:LISTEN | grep -v rapportd | grep -v com.dock | grep -v COMMAND | grep -v ControlCe | awk '{print $2}' | sort -u); do
	echo "pid: $pid"
	kill $pid
done
