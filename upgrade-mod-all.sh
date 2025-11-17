#!/bin/bash

FILES=$(fd go.mod ~/dev)
BRANCH="chore/upgrade-go-shared"
PR_NAME="chore(shared code): update go-shared version"
COMMIT_MSG="upgrade go shared"

for F in $FILES; do
	F=$(dirname $F)
	cd $F
	echo -e "${C_CYAN}updating $F${C_RESET}"
	mod

	git commit -am "$COMMIT_MSG" >/dev/null
	git push >/dev/null

	gh pr create --title "$PR_NAME" --body "$COMMIT_MSG" --base main --head "$BRANCH_NAME" --draft >/dev/null ||
		gh pr create --title "$PR_NAME" --body "$COMMIT_MSG" --base master --head "$BRANCH_NAME" --draft >/dev/null
done
