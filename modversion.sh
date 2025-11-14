#!/bin/bash

FILES=$(fd go.mod ~/dev)
MODULE=$(echo "${1:-github.com/signalscode/go-shared}" | xargs)

for F in $FILES; do
	CONTENTS=$(cat $F)
	if [[ $CONTENTS == *"$MODULE "* ]]; then
		VERSION=$(cat $F | grep "$MODULE " | grep -v "replace" | cut -d" " -f2)
		echo "$(printf "%-60s" $(dirname $F)) $VERSION"
	fi
done
