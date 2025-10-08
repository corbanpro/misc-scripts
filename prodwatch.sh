#!/bin/bash

if [ -z "$1" ]; then
	watch "kubectl get pods | grep -v beta"
else
	watch "kubectl get pods | grep -v beta -e \"$1\" "
fi
