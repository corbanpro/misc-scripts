#!/bin/bash

secret=$(kubectl get secret "$1" -o json)

if [ $? -ne 0 ]; then
	echo "Error: Failed to extract secret."
	return
fi

# Extract keys and values, decode them, and format as KEY=VALUE
output=$(echo "$secret" | jq -r '.data | to_entries | .[] | "\(.key)=\(.value | @base64d)"')

echo -e "$output"
