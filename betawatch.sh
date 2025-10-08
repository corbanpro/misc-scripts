#!/bin/bash

if [ -z "$1" ]; then
	watch "kubectl get pods | grep -e beta -e NAME"
else
	watch "kubectl get pods | grep -e beta -e NAME | grep -e NAME -e \"$1\" "
fi
