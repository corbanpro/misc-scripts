#!/bin/bash

FILES=$(fd go.mod ~/dev)

for F in $FILES; do
	CONTENTS=$(cat $F)
	if [[ $CONTENTS == *"github.com/signalscode/go-shared "* ]]; then
		VERSION=$(cat $F | grep "github.com/signalscode/go-shared " | grep -v "replace" | cut -d" " -f2)
		echo "$(printf "%-60s" $(dirname $F)) $VERSION"
	fi
done
