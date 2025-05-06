#!/bin/bash

if [[ ! -d "/tmp/repo_updates" ]]; then
	mkdir -p /tmp/repo_updates
fi

while getopts "mvf" opt; do
	case $opt in
	v)
		verbose=true
		;;
	f)
		fast=true
		;;
	m)
		stayOnMain=true
		;;
	*)
		echo "Unknown flag"
		;;
	esac
done

repos=("channel-manager" "chat-client" "content-pages" "credentials-service" "data-fetch" "integration-crm" "integration-data-enrichment" "ops" "portal" "profile-pages" "signals-core" "signals-webhooks")
migrations=("credentials-service" "data-enrichment" "data-fetch" "integration-crm" "signals-core")

function update_repo {
	dir=$1
	cd "$HOME/dev/$dir"

	echo -e "Starting Update: \033[32m$dir\033[0m"

	echo -e "\033[34mSwitching to main branch on $dir\033[0m"
	if [[ $verbose == true ]]; then
		git switch $(git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@')
	else
		git switch $(git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@') --quiet
	fi

	echo -e "\033[34mPulling Changes on $dir\033[0m"
	if [[ $verbose == true ]]; then
		git pull
	else
		git pull --no-stat --quiet
	fi

	if [[ " ${migrations[@]} " =~ " ${dir} " ]]; then
		echo -e "\033[36mRunning Migrations on $dir\033[0m"
		if [[ $verbose == true ]]; then
			make migrate
		else
			make migrate >>/dev/null
		fi
	fi

	if [[ $stayOnMain != true ]]; then
		echo -e "\033[34mSwitching back to previous branch on $dir\033[0m"
		if [[ $verbose == true ]]; then
			git switch -
		else
			git switch - --quiet
		fi
	fi

	echo -e "\033[32mUpdate Complete: $dir\033[0m"

}

# Run each update in the background
for dir in "${repos[@]}"; do
	# check if fast flag is set
	if [[ $fast == true ]]; then
		update_repo "$dir" &
	else
		update_repo "$dir"
	fi
done

# Wait for all background jobs to finish
wait

echo -e "\n\033[32mAll updates completed.\033[0m"
