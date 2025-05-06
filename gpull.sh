#!/bin/bash

# Set the base directory to the first argument, or use the current directory
directory=$HOME/dev

verbose=0
while getopts "fv" opt; do
	case $opt in
	v)
		verbose=1
		;;
	f)
		fast=true
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
		echo "pulling from: $dir"
		if [ "$fast" == "true" ]; then
			git -C $dir pull &
		else
			git -C $dir pull
		fi
		echo
	else
		check_subdirectories "$dir"
	fi
}

# Function to traverse subdirectories, skipping ignored paths
check_subdirectories() {
	local dir=$1
	local ignore=(".go" ".aws" ".cache" ".cargo" ".cdk" ".cfm-schema" ".docker" ".gradle" ".hg" ".java" ".npm" ".nuxt" ".rustup" ".stack-work" ".svn" ".vim" ".wakatime" "dist" "node_modules" "target" "vendor" ".local" ".ebcli-virtual-env" ".dotnet" ".autojump" "/./" "/../")
	while IFS= read -r subdirectory; do
		if [ -d "$subdirectory" ]; then
			if [[ " ${ignore[@]} " =~ " ${subdirectory##*/} " ]]; then
				continue
			fi
			check_directory "$subdirectory"
		fi
	done < <(fd --type d -d 1 . "$dir")
}

check_directory $directory

wait

echo "All git repositories have been updated."
