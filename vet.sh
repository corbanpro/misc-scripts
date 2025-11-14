#!/bin/bash

DIR="${1:-./...}"

make -q templ 2>/dev/null
STATUS=$?

set -e

if [ $STATUS -ne 2 ]; then
	make templ
fi

go vet $DIR
