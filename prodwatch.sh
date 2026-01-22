#!/bin/bash

KUBE_COMMAND="kubectl get pods | grep -v beta"

GREP_PATTERNS="-e NAME"

if [ "$#" -gt 0 ]; then
	for ARG in "$@"; do
		GREP_PATTERNS+=" -e \"$ARG\""
	done

	watch "$KUBE_COMMAND | grep $GREP_PATTERNS"
else
	watch "$KUBE_COMMAND"
fi
