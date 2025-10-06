#!/bin/bash

mode="uncommitted"

push_mode=1
commit_mode=1

while [[ $# -gt 0 ]]; do
	case "$1" in
	-c)
		push_mode=0
		shift
		;;
	-p)
		commit_mode=0
		shift
		;;
	esac
done

# Function to check for uncommitted changes
check_uncommitted_changes() {
	local dir=$1
	if [ -n "$(git -C "$dir" status --porcelain)" ]; then
		echo "$dir"
	fi
}

# Function to check for unpushed commits
check_unpushed_commits() {
	local dir=$1
	push_status=$(git -C "$dir" rev-list --left-right --count @{upstream}...HEAD 2>/dev/null)
	if [ $? -ne 0 ]; then
		echo "Warning: Repository in $dir has no upstream set."
		return
	fi
	local behind_ahead=(${push_status})
	local ahead=${behind_ahead[1]}
	if [ "$ahead" -gt 0 ]; then
		echo "$dir"
	fi
}

# Function to traverse directories and check for git repositories
check_directory() {
	local dir=$1
	if [ -d "$dir/.git" ]; then
		if [ "$mode" == "unpushed" ]; then
			check_unpushed_commits "$dir"
		else
			check_uncommitted_changes "$dir"
		fi
	else
		check_subdirectories "$dir"
	fi
}

# Function to traverse subdirectories, skipping ignored paths
check_subdirectories() {
	local dir=$1
	local ignore=(".go" ".aws" ".cache" ".cargo" ".cdk" ".cfm-schema" ".docker" ".gradle" ".hg" ".java" ".npm" ".nuxt" ".rustup" ".stack-work" ".svn" ".vim" ".wakatime" "dist" "node_modules" "target" "vendor" ".local" ".ebcli-virtual-env" ".dotnet" ".autojump")
	fd --type d -d 1 . "$dir" | while read -r subdirectory; do
		if [ -d "$subdirectory" ]; then
			if [[ " ${ignore[@]} " =~ " ${subdirectory##*/} " ]]; then
				continue
			fi
			check_directory "$subdirectory"
		fi
	done
}

dirs=(~/dev ~/.scripts ~/repos ~/.config ~/.config/nvim)

# Run the script
if [[ "$commit_mode" -eq 1 ]]; then
	echo "Checking for untracked changes"

	for d in "${dirs[@]}"; do
		check_directory "$d"
	done
fi

mode="unpushed"

if [[ "$commit_mode" -eq 1 && "$push_mode" -eq 1 ]]; then
	echo
fi

if [[ "$push_mode" -eq 1 ]]; then
	echo "Checking for unpushed commits"

	for d in "${dirs[@]}"; do
		check_directory "$d"
	done
fi
