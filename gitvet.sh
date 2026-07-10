#!/usr/bin/env bash

maketempl

# Find uncommitted Go files (modified, staged, or untracked)
# 1. git status --porcelain ensures a stable, machine-readable output.
# 2. grep filters for lines ending in .go.
# 3. cut removes the Git status prefix to get just the file paths.
files=$(git status --porcelain | grep '\.go$' | cut -c 4-)

if [ -z "$files" ]; then
	echo "No uncommitted Go changes found."
	exit 0
fi

# Extract unique directories (packages) from the file list
# 1. xargs dirname gets the directory for each file.
# 2. sort -u removes duplicate directories so we don't vet the same package twice.
packages=$(echo "$files" | xargs -L 1 dirname | sort -u)

echo "Running go vet on modified packages..."
echo "--------------------------------------"

# Run go vet on each unique package directory
echo "$packages" | while read -r dir; do
	echo "=> Vetting: ./$dir"
	# Append ./ to the path so Go recognizes it as a local package directory
	go vet "./$dir"
done
