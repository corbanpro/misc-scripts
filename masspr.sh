#!/bin/bash

set -euo pipefail

# Check for required arguments
if [ "$#" -ne 4 ]; then
	echo "Usage: $0 <working_directory> <branch_name> <pr_name> <commit_message>"
	echo "Example: $0 ./ feature/update-pr \"Update configs\" \"Update configuration files\""
	exit 1
fi

ROOT_DIR="$1" # Change this if needed
BRANCH_NAME="$2"
PR_NAME="$3"
COMMIT_MSG="$4"

# Loop through directories (depth 1)
for dir in "$ROOT_DIR"/*/; do
	# Check if directory is a git repository
	if [ -d "$dir/.git" ]; then
		echo "Processing repo: $dir"
		cd "$dir"

		# Check for untracked or modified files
		if [ -n "$(git status --porcelain)" ]; then
			echo "Found changes in $dir"

			# Create branch (overwrite if exists)
			git checkout -B "$BRANCH_NAME"

			# Stage all changes
			git add .

			# Commit
			git commit -m "$COMMIT_MSG"

			# Push branch to remote
			git push -u origin "$BRANCH_NAME"

			# Create PR targeting main branch
			gh pr create --title "$PR_NAME" --body "$COMMIT_MSG" --base main --head "$BRANCH_NAME" ||
				gh pr create --title "$PR_NAME" --body "$COMMIT_MSG" --base master --head "$BRANCH_NAME"

		else
			echo "No changes in $dir"
		fi

		# Return to root directory
		cd "$ROOT_DIR"
	fi
done

echo "Done!"
