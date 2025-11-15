#!/bin/bash

FILES=$(fd go.mod ~/dev)
PRS=()
BRANCH="chore/upgrade-go-shared"
PR_NAME="chore(shared code): update go-shared version"
COMMIT_MSG="upgrade go shared"

for F in $FILES; do
	F=$(dirname $F)
	cd $F
	if [ -z "$(git status --porcelain)" ]; then
		echo -e "${C_CYAN}updating $F${C_RESET}"
		mod
		if [ -n "$(git status --porcelain)" ]; then
			REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)
			gh api -X DELETE "repos/$REPO/git/refs/heads/$BRANCH" 2>&1 >/dev/null
			git branch -D "$BRANCH" 2>&1 >/dev/null
			gitchange "$BRANCH" "$PR_NAME" "$COMMIT_MSG"
		else
			echo -e "${C_CYAN}No update required for $F${C_RESET}"
		fi
	else
		echo -e "${C_RED}Git status is not up to date for $F${C_RESET}"
	fi
done

for PR in $PRS; do
	echo $PR
done
