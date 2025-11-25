#!/bin/bash

if [ -z "$1" ]; then
	watch "kubectl get pods | grep -v beta"
else
	watch "kubectl get pods | grep -v beta | grep -e NAME -e \"$1\" "
fi
