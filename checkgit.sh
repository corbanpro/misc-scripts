#!/bin/bash

# Default values
directory=$(pwd)
mode="uncommitted"

# Parse arguments
while [[ $# -gt 0 ]]; do
	case $1 in
	-p)
		mode="unpushed"
		shift
		;;
	*)
		directory=$1
		shift
		;;
	esac
done

# Validate the directory
if [ ! -d "$directory" ]; then
	echo "Error: Directory does not exist."
	exit 1
fi

if [ ! -r "$directory" ]; then
	echo "Error: Directory is not readable."
	exit 1
fi

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
	local ignore=(".aws" ".cache" ".cargo" ".cdk" ".cfm-schema" ".docker" ".gradle" ".hg" ".java" ".npm" ".nuxt" ".rustup" ".stack-work" ".svn" ".vim" ".wakatime" "dist" "node_modules" "target" "vendor" ".local")
	for subdirectory in "$dir"/{.*,**}; do
		if [ -d "$subdirectory" ]; then
			if [[ " ${ignore[@]} " =~ " ${subdirectory##*/} " ]]; then
				continue
			fi
			check_directory "$subdirectory"
		fi
	done
}

# Run the script
check_directory "$directory"
