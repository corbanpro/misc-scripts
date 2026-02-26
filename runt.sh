#!/bin/bash

DIR="${1:-./...}"

maketempl

go test -v "${1:-.}"/... | grep -v "no test files" | grep -v "failed to load godotenv" | grep -v '\\' | grep -v "coverage: 0.0%" | grep -v "failed to load .env" | grep -v "Finished running "
exit_code=${PIPESTATUS[0]}

if [ $exit_code -eq 0 ]; then
	echo -e "\n${C_GREEN}All Tests Passed!!!${C_RESET}"
else
	echo -e "\n${C_RED}TESTS FAILED!!!${C_RESET}"
fi

exit $exit_code
