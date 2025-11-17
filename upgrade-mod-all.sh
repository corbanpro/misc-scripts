#!/bin/bash

FILES=$(fd go.mod ~/dev)
BRANCH="chore/upgrade-go-shared"
PR_NAME="chore(shared code): update go-shared version"
COMMIT_MSG="upgrade go shared"

for F in $FILES; do
	F=$(dirname $F)
	cd $F
	echo -e "\n${C_CYAN}updating $F${C_RESET}"
	mod

	if [ -n "$(git status --porcelain)" ]; then
		git add . >/dev/null
		git commit -m "$COMMIT_MSG" >/dev/null
		echo -e "${C_GREEN}committed changes for $F${C_RESET}"

		git push >/dev/null
		echo -e "${C_GREEN}pushed changes for $F${C_RESET}"

		# gh pr create --title "$PR_NAME" --body "$COMMIT_MSG" --base main --head "$BRANCH_NAME" --draft >/dev/null ||
		# 	gh pr create --title "$PR_NAME" --body "$COMMIT_MSG" --base master --head "$BRANCH_NAME" --draft >/dev/null
		# echo -e "${C_GREEN}created pr for $F${C_RESET}"
	else
		echo "no update needed"
	fi
done

# read -p "run update in $MODE mode? [Y/n]: " SHOULD_RUN
#
# if [[ $SHOULD_RUN == "n" ]]; then
# 	exit 0
# fi
#
# for F in $FILES; do
# 	F=$(dirname $F)
# 	cd $F
# 	echo -e "${C_CYAN}updating $F${C_RESET}"
# 	mod
#
# 	if [[ $MODE == "commit" ]]; then
# 		if [ -n "$(git status --porcelain)" ]; then
# 			CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
# 			if [[ "$CURRENT_BRANCH" == "main" || "$CURRENT_BRANCH" == "master" ]]; then
# 				echo "switching to branch: $BRANCH"
# 				git checkout -b "$BRANCH_NAME" >/dev/null
# 			fi
# 			echo "committing changes"
# 			git commit -am "$COMMIT_MSG" >/dev/null
# 			git push >/dev/null
# 			echo -e "${C_CYAN}Pushed changes for $F${C_RESET}"
# 		else
# 			echo -e "${C_CYAN}No update required for $F${C_RESET}"
# 		fi
# 	elif [[ $MODE == "push" ]]; then
# 		if [ -n "$(git status --porcelain)" ]; then
# 			REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)
# 			gh api -X DELETE "repos/$REPO/git/refs/heads/$BRANCH" 2>&1 >/dev/null
# 			git branch -D "$BRANCH" 2>&1 >/dev/null
# 			gitchange "$BRANCH" "$PR_NAME" "$COMMIT_MSG"
# 		else
# 			echo -e "${C_CYAN}No update required for $F${C_RESET}"
# 		fi
# 	fi
# done
#
