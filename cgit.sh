#!/bin/bash

dirs=(~/dev ~/.scripts ~/repos ~/.config ~/.config/nvim)

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

# Function to check if the branch is on master
check_branch_not_master() {
	local dir="$1"
	local branch=$(git -C "$dir" rev-parse --abbrev-ref HEAD 2>/dev/null)

	if [ -z "$branch" ]; then
		echo "Failed to get branch for $dir" >&2
		return 1
	fi

	# Check if branch is NOT master or main
	if [ "$branch" != "master" ] && [ "$branch" != "main" ]; then
		echo "$dir"
	fi
}

# Function to traverse directories and check for git repositories
check_directory() {
	local dir=$1
	if [ -d "$dir/.git" ]; then
		case "$mode" in
		unpushed) check_unpushed_commits "$dir" ;;
		uncommitted) check_uncommitted_changes "$dir" ;;
		master) check_branch_not_master "$dir" ;;
		esac
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

mode="uncommitted"
echo "Checking for untracked changes"

for d in "${dirs[@]}"; do
	check_directory "$d"
done

mode="unpushed"
echo
echo "Checking for unpushed commits"

for d in "${dirs[@]}"; do
	check_directory "$d"
done

mode="master"
echo
echo "Checking for branches not on main"

for d in "${dirs[@]}"; do
	check_directory "$d"
done
