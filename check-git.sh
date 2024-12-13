#!/bin/bash

# copilot: write a script that finds all git repositories in a directory and checks if they have unpushed changes
# recursively check directory after subdirectory
# default to the current directory if none is provided

# Usage: ./check-git.sh /path/to/directory

# check if a directory is provided
# if not, use the current directory
# if provided, check if it exists
# if it does not exist, exit with an error message
# if it exists, check if it is a directory
# if it is not a directory, exit with an error message
# if it is a directory, check if it is readable
# if it is not readable, exit with an error message

# check if the provided directory is a git repository
# if it is not a git repository, check subdirectories
# if it is a git repository, check if there are unpushed changes
# if there are unpushed changes, print the repository path
# if there are no unpushed changes, continue checking subdirectories
# if there are no subdirectories, exit
# if there are subdirectories, repeat the process

if [ -z "$1" ]; then
	directory=$(pwd)
else
	directory=$1
fi

if [ ! -d "$directory" ]; then
	echo "Error: Directory does not exist."
	exit 1
fi

if [ ! -r "$directory" ]; then
	echo "Error: Directory is not readable."
	exit 1
fi

check_directory() {
	local dir=$1
	if [ -d "$dir/.git" ]; then
		if [ -n "$(git -C $dir status --porcelain)" ]; then
			echo "$dir"
		fi
	else
		check_subdirectories "$dir"
	fi
}

check_subdirectories() {
	local dir=$1
	local ignore=(".aws" ".cache" ".cargo" ".cdk" ".cfm-schema" ".docker" ".gradle" ".hg" ".java" ".npm" ".nuxt" ".nuxt" ".rustup" ".stack-work" ".svn" ".vim" ".wakatime" "dist" "node_modules" "target" "vendor" ".local")
	for subdirectory in "$dir"/{.*,**}; do
		if [ -d "$subdirectory" ]; then
			if [[ " ${ignore[@]} " =~ " ${subdirectory##*/} " ]]; then
				continue
			fi
			check_directory "$subdirectory"
		fi
	done
}

check_directory "$directory"
