#!/bin/bash

set -euo pipefail

LC_CTYPE=C find . -type f \
	-not -path '*/.git/*' \
	-not -path '*/node_modules/*' \
	-not -path '*/vendor/*' \
	-exec sed -i "" "$1" {} +
