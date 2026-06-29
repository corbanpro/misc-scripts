#!/bin/bash

DURATION=2m
if [[ -n $1 ]]; then
	DURATION=$1
fi

timeout ${DURATION} cloud-sql-proxy --auto-iam-authn -p 54224 chatfunnels:us-central1:beta
status=$?

if [ $status -eq 124 ] || [ $status -eq 0 ]; then
	exit 0
else
	exit $status
fi
