#!/bin/bash

set -euo pipefail

# Check for required arguments
if [ "$#" -ne 4 ]; then
	echo "Usage: $0 <working_directory> <branch_name> <pr_name> <commit_message>"
	echo "Example: $0 ./ feature/update-pr \"Update configs\" \"Update configuration files\""
	exit 1
fi

ROOT_DIR=$(realpath $1)
BRANCH_NAME=$2
PR_NAME=$3
COMMIT_MSG=$4

# Loop through directories (depth 1)
for dir in "$ROOT_DIR"/*/; do
	cd $dir
	# Check if directory is a git repository
	if [ -d ".git/" ]; then
		# Check for untracked or modified files
		if [ -n "$(git status --porcelain)" ]; then
			gitchange $BRANCH_NAME $PR_NAME $COMMIT_MSG
		fi
	fi
done
