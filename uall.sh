#!/bin/bash

repos=(
	"channel-manager"
	"chat-client"
	"content-pages"
	"credentials-service"
	"data-fetch"
	"data-miner"
	"integration-crm"
	"integration-data-enrichment"
	"ops"
	"portal"
	"profile-pages"
	"signals-core"
	"signals-webhooks"
	"docs"
	"signals-mas"
	"nerve"
	"go-shared"
	"integration-messaging-service"
	"integration-ads"
	"signals-score-service"
	"chat-inator"
	"release-status"
)

migrations=(
	"credentials-service"
	"data-enrichment"
	"nerve"
	"data-miner"
	"integration-crm"
	"signals-core"
	"signals-mas"
	"integration-messaging-service"
)

templ=(
	"signals-core"
	"nerve"
	"go-shared"
	"signals-mas"
)

if [[ ! -d "/tmp/repo_updates" ]]; then
	mkdir -p /tmp/repo_updates
fi

while getopts "nvr:" opt; do
	case $opt in
	v) verbose=true ;;
	n) not_repo=true ;;
	r) repo="$OPTARG" ;;
	*) echo "Unknown flag" ;;
	esac
done

function update_repo {
	dir=$1
	cd "$HOME/dev/$dir"

	echo -e "Starting Update: \033[32m$dir\033[0m"

	echo -e "\033[34mSwitching to main branch on $dir\033[0m"
	if [[ $verbose == true ]]; then
		git switch $(git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@') || return 1
	else
		git switch $(git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@') --quiet || return 1
	fi

	echo -e "\033[34mPulling Changes on $dir\033[0m"
	if [[ $verbose == true ]]; then
		git pull || return 1
	else
		git pull --no-stat --quiet || return 1
	fi

	if [[ " ${templ[@]} " =~ " ${dir} " ]]; then
		echo -e "\033[34mUpdating templ on $dir\033[0m"

		if [[ $verbose == true ]]; then
			rm -rf ./**/*_templ.go
			make templ || return 1
		else
			rm -rf ./**/*_templ.go
			make templ >>/dev/null || return 1
		fi
	fi

	if [[ " ${migrations[@]} " =~ " ${dir} " ]]; then
		echo -e "\033[36mRunning Migrations on $dir\033[0m"
		if [[ $verbose == true ]]; then
			make migrate || return 1
		else
			make migrate >>/dev/null || return 1
		fi
	fi

	echo -e "\033[36mtrimming merged branches for $dir\033[0m"
	(git branch --merged main 2>/dev/null || git branch --merged master) | grep -vE "^\s*main|^\s*master|^\*" | while read -r branch; do
		git branch -d "$branch" >/dev/null
	done

	echo -e "\033[32mUpdate Complete: $dir\033[0m"
	echo
}

function update_failed {
	dir=$1
	echo -e "\033[31mUpdate Failed: $dir\033[0m"
}

function run_update {
	dir=$1
	update_repo $dir || update_failed $dir
}

function run {
	run_update $1 &
}

backupall

echo

if [[ -n "$repo" ]]; then
	for r in "${repos[@]}"; do
		if [[ $not_repo == true ]]; then
			if [[ ! "${r}" =~ "${repo}" ]]; then
				run $r
			fi
		else
			if [[ "${r}" =~ "${repo}" ]]; then
				run $r
			fi
		fi
	done
else
	for r in "${repos[@]}"; do
		run $r
	done
fi

wait

echo -e "\033[32mAll updates completed.\033[0m"
