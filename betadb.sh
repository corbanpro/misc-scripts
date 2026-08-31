#!/bin/bash

DURATION=2m
if [[ -n $1 ]]; then
	DURATION=$1
fi

# --foreground keeps the proxy in this process group so Ctrl-C reaches it.
# Without that, timeout isolates the proxy and it survives the script.
# -k 5s SIGKILLs if the proxy ignores the first signal.
timeout --foreground -k 5s ${DURATION} cloud-sql-proxy --auto-iam-authn -p 54224 chatfunnels:us-central1:beta
status=$?

# 124 = duration expired; 130 = Ctrl-C
if [ $status -eq 124 ] || [ $status -eq 130 ] || [ $status -eq 0 ]; then
	exit 0
else
	exit $status
fi
