#!/bin/bash

DIR="${1:-./...}"

make -q templ 2>/dev/null
STATUS=$?

if [ $STATUS -ne 2 ]; then
	make templ || echo -e "\n${C_RED}FAILED TO MAKE TEMPL!!!${C_RESET}" && exit 1
fi

go test -v "${1:-.}"/... | grep -v "no test files" | grep -v "failed to load godotenv" | grep -v '\\' | grep -v "coverage: 0.0%"
exit_code=${PIPESTATUS[0]}

if [ $exit_code -eq 0 ]; then
	echo -e "\n${C_GREEN}All Tests Passed!!!${C_RESET}"
else
	echo -e "\n${C_RED}TESTS FAILED!!!${C_RESET}"
fi

exit $exit_code
