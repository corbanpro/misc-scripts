#!/bin/bash

set -euo pipefail

# Check for required arguments
if [ "$#" -ne 3 ]; then
	echo --e "
ERROR: incorrect arguments for gitchange
Usage: gitchange <branch_name> <pr_name> <commit_message>
Example: gitchange feature/update-pr \"Update configs\" \"Update configuration files\""
	exit 1
fi

BRANCH_NAME=$1
PR_NAME=$2
COMMIT_MSG=$3

echo "checking out $BRANCH_NAME"
git checkout -B "$BRANCH_NAME" >/dev/null
echo "committing changes"
git commit -am "$COMMIT_MSG" >/dev/null
echo "pushing to $BRANCH_NAME"
git push -u origin "$BRANCH_NAME" >/dev/null

echo "creating PR"
gh pr create --title "$PR_NAME" --body "$COMMIT_MSG" --base main --head "$BRANCH_NAME" --draft >/dev/null ||
	gh pr create --title "$PR_NAME" --body "$COMMIT_MSG" --base master --head "$BRANCH_NAME" --draft >/dev/null

echo -e "${C_CYAN}Created PR for $PWD${C_RESET}"
