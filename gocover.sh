#!/bin/bash

TARGET="${1:-.}"

if [ -d "$TARGET" ]; then
	TARGET="$TARGET/..."
elif [ ! -f "$TARGET" ]; then
	echo "$TARGET is not a file or directory"
	exit 1
fi

maketempl

echo

go test -coverprofile=coverage.out ${TARGET} && go tool cover -html=coverage.out
