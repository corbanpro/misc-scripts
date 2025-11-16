#!/bin/bash

FILES=$(fd go.mod ~/dev)
BRANCH="chore/upgrade-go-shared"
PR_NAME="chore(shared code): update go-shared version"
COMMIT_MSG="upgrade go shared"

MODE="module"
if [[ "$1" == "-p" ]]; then
	MODE="push"
elif [[ "$1" == "-c" ]]; then
	MODE="commit"
fi

read -p "run update in $MODE mode? [Y/n]: " SHOULD_RUN

if [[ $SHOULD_RUN == "n" ]]; then
	exit 0
fi

for F in $FILES; do
	F=$(dirname $F)
	cd $F
	echo -e "${C_CYAN}updating $F${C_RESET}"
	mod

	if [[ $MODE == "commit" ]]; then
		if [ -n "$(git status --porcelain)" ]; then
			CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
			if [[ "$CURRENT_BRANCH" == "main" || "$CURRENT_BRANCH" == "master" ]]; then
				echo "switching to branch: $BRANCH"
				git checkout -b "$BRANCH_NAME" >/dev/null
			fi
			echo "committing changes"
			git commit -am "$COMMIT_MSG" >/dev/null
			git push >/dev/null
			echo -e "${C_CYAN}Pushed changes for $F${C_RESET}"
		else
			echo -e "${C_CYAN}No update required for $F${C_RESET}"
		fi
	elif [[ $MODE == "push" ]]; then
		if [ -n "$(git status --porcelain)" ]; then
			REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)
			gh api -X DELETE "repos/$REPO/git/refs/heads/$BRANCH" 2>&1 >/dev/null
			git branch -D "$BRANCH" 2>&1 >/dev/null
			gitchange "$BRANCH" "$PR_NAME" "$COMMIT_MSG"
		else
			echo -e "${C_CYAN}No update required for $F${C_RESET}"
		fi
	fi
done
