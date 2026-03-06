#!/bin/bash

set -euo pipefail

# Check for required arguments
if [ "$#" -ne 4 ]; then
	argerr masspr
	echo "USAGE: masspr <working_directory> <branch_name> <pr_name> <commit_message>"
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
			echo "checking out $BRANCH_NAME"
			git checkout -b "$BRANCH_NAME" >/dev/null
			echo "committing changes"
			git add . >/dev/null
			git commit -m "$COMMIT_MSG" >/dev/null
			echo "pushing to $BRANCH_NAME"
			git push -u origin "$BRANCH_NAME" >/dev/null

			echo "creating PR"
			gh pr create --title "$PR_NAME" --body "$COMMIT_MSG" --base main --head "$BRANCH_NAME" --draft >/dev/null ||
				gh pr create --title "$PR_NAME" --body "$COMMIT_MSG" --base master --head "$BRANCH_NAME" --draft >/dev/null

			echo -e "${C_CYAN}Created PR for $PWD${C_RESET}"
		fi
	fi
done
