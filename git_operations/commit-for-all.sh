#!/bin/bash

set -e

FILES=$(fd go.mod ~/dev)
# COMMIT_MSG="chore: upgrade go shared"
COMMIT_MSG="chore: run templ fmt"

function update_msg() {
	echo -e "${C_GREEN}$1${C_RESET}"
}

function operation() {
	update_msg "running templ fmt"
	templ fmt .
}

for F in $FILES; do
	F=$(dirname $F)
	cd $F
	echo
	current_branch=$(git branch --show-current)
	update_msg "updating $F on branch ${current_branch}"
	if [[ "$current_branch" == "main" || "$current_branch" == "main" ]]; then
		update_msg "Skipping update on main branch"
		continue
	fi

	operation

	if [ -n "$(git status --porcelain)" ]; then
		git add . >/dev/null
		git commit -m "$COMMIT_MSG" >/dev/null
		update_msg "committed changes for $F"

		git push -q || git push -q --set-upstream origin ${BRANCH}
		update_msg "pushed changes for $F"
	else
		echo "no update needed"
	fi
done
