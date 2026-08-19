#!/bin/bash

ctx1="docker-desktop"
ctx2="gke_chatfunnels_us-central1-a_production"

current=$(kubectl config current-context 2>/dev/null)

if [[ "$current" == "$ctx1" ]]; then
	kubectl config use-context "$ctx2"
elif [[ "$current" == "$ctx2" ]]; then
	kubectl config use-context "$ctx1"
else
	echo "Current context ('${current:-none}') is neither target context."
	echo "Defaulting to $ctx1..."
	kubectl config use-context "$ctx1"
fi
