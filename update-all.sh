#!/bin/bash

if [[ ! -d "/tmp/repo_updates" ]]; then
	mkdir -p /tmp/repo_updates
fi

while getopts "mvsg" opt; do
	case $opt in
	v)
		verbose=true
		;;
	s)
		slow=true
		;;
	m)
		stayOnMain=true
		;;
	g)
		generate=true
		stayOnMain=true
		;;
	*)
		echo "Unknown flag"
		;;
	esac
done

repo=$1

repos=("channel-manager" "chat-client" "content-pages" "credentials-service" "data-fetch" "integration-crm" "integration-data-enrichment" "ops" "portal" "profile-pages" "signals-core" "signals-webhooks")
migrations=("credentials-service" "data-enrichment" "data-fetch" "integration-crm" "signals-core")
generations=("credentials-service" "integration-crm" "integration-data-enrichment" "signals-core" "signals-webhooks")

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

	if [[ " ${migrations[@]} " =~ " ${dir} " ]]; then
		echo -e "\033[36mRunning Migrations on $dir\033[0m"
		if [[ $verbose == true ]]; then
			make migrate || return 1
		else
			make migrate >>/dev/null || return 1
		fi
	fi

	if [[ " ${generations[@]} " =~ " ${dir} " && $generate == true ]]; then
		echo -e "\033[36mRunning Generate on $dir\033[0m"
		if [[ $verbose == true ]]; then
			make generate || return 1
		else
			make generate >>/dev/null || return 1
		fi
	fi

	cleanup $dir
	echo -e "\033[32mUpdate Complete: $dir\033[0m"
	echo
}

function update_failed {
	dir=$1
	echo -e "\033[31mUpdate Failed: $dir\033[0m"
}

function cleanup {
	dir=$1
	if [[ $stayOnMain != true ]]; then
		echo -e "\033[34mSwitching back to previous branch on $dir\033[0m"
		if [[ $verbose == true ]]; then
			git switch -
		else
			git switch - --quiet
		fi
	fi
}

function run_update {
	dir=$1
	update_repo $dir || (update_failed $dir && cleanup $dir)
}

if [[ -z "$repo" ]]; then
	for dir in "${repos[@]}"; do
		if [[ $slow == true ]]; then
			run_update $dir
		else
			run_update $dir &
		fi
	done
else
	for r in "${repos[@]}"; do
		if [[ "${r}" =~ "${repo}" ]]; then
			run_update $r
			updated=1
		fi

	done
	if [[ updated -ne 1 ]]; then
		echo -e "\033[31mNot a valid repo: $repo\033[0m"
	fi
fi

wait

echo -e "\033[32mAll updates completed.\033[0m"
