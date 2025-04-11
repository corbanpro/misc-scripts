#!/bin/bash

# Set the base directory to the first argument, or use the current directory
directory=$HOME
verbose=0

while [[ $# -gt 0 ]]; do
	case "$1" in
	--verbose)
		verbose=1
		shift
		;;
	*)
		directory=$1
		shift
		;;
	esac
done

# Function to traverse directories and check for git repositories
check_directory() {
	local dir=$1
	if [ "$verbose" -eq 1 ]; then
		echo "Checking directory: $dir"
	fi
	if [ -d "$dir/.git" ]; then
		(
			cd $dir
			echo "pulling from: $dir"
			git pull
			echo
		)
	else
		check_subdirectories "$dir"
	fi
}

# Function to traverse subdirectories, skipping ignored paths
check_subdirectories() {
	local dir=$1
	local ignore=(".go" ".aws" ".cache" ".cargo" ".cdk" ".cfm-schema" ".docker" ".gradle" ".hg" ".java" ".npm" ".nuxt" ".rustup" ".stack-work" ".svn" ".vim" ".wakatime" "dist" "node_modules" "target" "vendor" ".local" ".ebcli-virtual-env" ".dotnet" ".autojump")
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
