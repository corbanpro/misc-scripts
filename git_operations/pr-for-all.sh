#!/bin/bash

set -e

FILES=$(fd go.mod ~/dev)
BRANCH="chore/upgrade-go-shared-context-$(($(date +%s%N) / 1000000))"
PR_NAME="chore(shared code): update go-shared version"
COMMIT_MSG="chore: upgrade go shared"

function operation() {
	mod
}

for F in $FILES; do
	F=$(dirname $F)
	cd $F
	echo -e "\n${C_CYAN}updating $F on branch $(git branch --show-current)${C_RESET} "
	operation

	if [ -n "$(git status --porcelain)" ]; then
		git checkout -b "$BRANCH"
		git add . >/dev/null
		git commit -m "$COMMIT_MSG" >/dev/null
		echo -e "${C_GREEN}committed changes for $F${C_RESET}"

		git push || git push --set-upstream origin ${BRANCH}
		echo -e "${C_GREEN}pushed changes for $F${C_RESET}"

		gh pr create --title "$PR_NAME" --body "$COMMIT_MSG" --base main --head "$BRANCH_NAME" --draft >/dev/null ||
			gh pr create --title "$PR_NAME" --body "$COMMIT_MSG" --base master --head "$BRANCH_NAME" --draft >/dev/null
		echo -e "${C_GREEN}created pr for $F${C_RESET}"
	else
		echo "no update needed"
	fi
done
