#!/bin/bash

make templ
go test -v "${1:-.}"/... | grep -v "no test files" | grep -v "failed to load godotenv" | grep -v '\\' | grep -v "coverage: 0.0%"
exit_code=${PIPESTATUS[0]}

if [ $exit_code -eq 0 ]; then
	echo -e "\n${C_BGREEN}All Tests Passed!!!${C_RESET}"
else
	echo -e "\n${C_BRED}TESTS FAILED!!!${C_RESET}"
fi

exit $exit_code
