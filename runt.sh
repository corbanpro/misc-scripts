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

go test -v "$TARGET" |
	grep -v "no test files" |
	grep -v "coverage: 0.0%" |
	grep -v "⏳ Waiting for Reaper" |
	grep -v "🔥 Reaper obtained from Docker for this test session" |
	grep -v "^Finished running \"" |
	grep -vE "Running batch [0-9]+ with [0-9]+ migration" |
	grep -v "Shell not found in container" |
	sed '\|github.com/testcontainers/testcontainers-go - Connected to docker:|,+11d'

exit_code=${PIPESTATUS[0]}

if [ $exit_code -eq 0 ]; then
	echo -e "\n${C_GREEN}All Tests Passed!!!${C_RESET}"
else
	echo -e "\n${C_RED}TESTS FAILED!!!${C_RESET}"
fi

exit $exit_code
