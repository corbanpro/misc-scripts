#!/bin/bash
set -euo pipefail

PATTERNS=(
	"github.com/chatfunnels/"
	"github.com/signalscode/"
)

echo "Finding direct dependencies..."

# Get only direct dependencies to avoid breaking on indirect pseudo-version errors
ALL_DEPS=$(go list -m -f '{{if not .Indirect}}{{.Path}}{{end}}' all 2>/dev/null || true)

# Fallback: if go list fails completely, parse go.mod directly
if [ -z "$ALL_DEPS" ]; then
	ALL_DEPS=$(awk '/require \(/,/\)/ { if ($1 !~ "//" && $1 != "require" && $1 != ")") print $1 }' go.mod)
fi

MATCHED_DEPS=()

for pattern in "${PATTERNS[@]}"; do
	for dep in $ALL_DEPS; do
		if [[ "$dep" == $pattern* ]]; then
			MATCHED_DEPS+=("$dep")
		fi
	done
done

if [ ${#MATCHED_DEPS[@]} -eq 0 ]; then
	echo "No dependencies found matching the specified patterns."
	exit 0
fi

echo "Found matching dependencies:"
printf ' - %s\n' "${MATCHED_DEPS[@]}"

for dep in "${MATCHED_DEPS[@]}"; do
	echo
	echo "--> go get '${dep}/pkg@latest'"
	go get "${dep}/pkg@latest" || go get "${dep}@latest"
done

echo ""
echo "Tidying module dependencies..."
go mod tidy

echo "Done!"
