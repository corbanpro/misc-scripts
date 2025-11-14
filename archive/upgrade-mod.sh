#!/bin/bash

set -e

/Users/corbanprocuniar/.local/bin/mod

git commit -am "upgrade go-shared"
git push

echo -e "\n${C_GREEN}Success!!${C_RESET}"
