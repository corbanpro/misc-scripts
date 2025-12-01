#!/bin/bash

set -euo pipefail

expr="$1"

while IFS= read -r file; do
	[ -z "$file" ] && continue
	sed -i '' "$expr" "$file"
done
