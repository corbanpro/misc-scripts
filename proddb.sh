#!/bin/bash

DURATION=30s
if [[ -n $1 ]]; then
	DURATION=$1
fi

timeout ${DURATION} cloud-sql-proxy --auto-iam-authn -p 54220 chatfunnels:us-central1:production-v2
status=$?

if [ $status -eq 124 ] || [ $status -eq 0 ]; then
	exit 0
else
	exit $status
fi
