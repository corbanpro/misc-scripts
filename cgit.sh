#!/bin/bash

dirs=(~/dev ~/.scripts ~/.config ~/.config/nvim)

check_ssh=0
for arg in "$@"; do
	case "$arg" in
	--ssh) check_ssh=1 ;;
	esac
done

print_dir() {
	local dir="${1/#$HOME/~}"
	echo -e "${C_CYAN}$(printf "%-36s" $dir) $2${C_RESET}"
}

# Function to check for uncommitted changes
check_uncommitted_changes() {
	local dir=$1
	if [ -n "$(git -C "$dir" status --porcelain)" ]; then
		print_dir "$dir"
	fi
}

# Function to check for unpushed commits
check_unpushed_commits() {
	local dir=$1
	if [ -z "$(git -C "$dir" remote)" ]; then
		return
	fi
	push_status=$(git -C "$dir" rev-list --left-right --count @{upstream}...HEAD 2>/dev/null)
	if [ $? -ne 0 ]; then
		echo "Warning: Repository in $dir has no upstream set."
		return
	fi
	local behind_ahead=(${push_status})
	local ahead=${behind_ahead[1]}
	if [ "$ahead" -gt 0 ]; then
		print_dir "$dir"
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
		print_dir "$dir" "$branch"
	fi
}

check_for_extra_branches() {
	local dir="$1"

	count=$(git -C "$dir" branch --format='%(refname:short)' | grep -v "^main$" | grep -v "^master$" | grep -v "^debug/.*" | grep -v "^draft/.*" | grep -v "^archive/.*" | grep -v "^x/.*" | wc -l)

	if [[ "$count" -gt 0 ]]; then
		print_dir "$dir" "$count"
	fi
}

# scp-style (git@host:path) or ssh://, rather than https://
is_ssh_remote() {
	local url="$1"
	case "$url" in
	ssh://* | git+ssh://*) return 0 ;;
	*://*) return 1 ;;
	*@*:*) return 0 ;;
	esac
	return 1
}

check_ssh_remotes() {
	local dir="$1"
	local name url
	while read -r name url _; do
		if is_ssh_remote "$url"; then
			print_dir "$dir" "$url"
		fi
	done < <(git -C "$dir" remote -v 2>/dev/null | awk '!seen[$2]++ { print $1, $2 }')
}

check_main_up_to_date() {
	local dir="$1"

	# Fetch latest refs (required)
	git -C "$dir" fetch origin main --quiet 2>/dev/null || git -C "$dir" fetch origin master --quiet

	# Check if we're on main
	local current_branch=$(git -C "$dir" rev-parse --abbrev-ref HEAD 2>/dev/null)

	if [[ "$current_branch" == "main" || "$current_branch" == "master" ]]; then
		# Check if local main is behind origin/main
		if [[ "$(git -C "$dir" rev-list --count main..origin/main 2>/dev/null || git -C "$dir" rev-list --count master..origin/master 2>/dev/null)" -gt 0 ]]; then
			print_dir "$dir"
		fi
	fi
}

# Function to traverse directories and check for git repositories
check_directory() {
	local dir=$1
	local resolved
	resolved=$(realpath "$dir" 2>/dev/null) || resolved="$dir"
	if [[ "$resolved" == "$HOME/dev/archive" || "$resolved" == "$HOME/dev/archive/"* ]]; then
		return
	fi
	# .git may be a directory or a gitfile (worktrees and submodules).
	if [ -e "$dir/.git" ]; then
		case "$mode" in
		unpushed) check_unpushed_commits "$dir" ;;
		uncommitted) check_uncommitted_changes "$dir" ;;
		master) check_branch_not_master "$dir" ;;
		extra_branches) check_for_extra_branches "$dir" ;;
		master_current) check_main_up_to_date "$dir" ;;
		ssh) check_ssh_remotes "$dir" ;;
		esac
	else
		check_subdirectories "$dir"
	fi
}

# Function to traverse subdirectories, skipping ignored paths
check_subdirectories() {
	local dir=$1
	local ignore=(".go" ".aws" ".cache" ".cargo" ".cdk" ".cfm-schema" ".docker" ".gradle" ".hg" ".java" ".npm" ".nuxt" ".rustup" ".stack-work" ".svn" ".vim" ".wakatime" "dist" "node_modules" "target" "vendor" ".local" ".ebcli-virtual-env" ".dotnet" ".autojump")
	# fd appends a trailing slash, which makes ${path##*/} empty and skips the ignore list.
	while IFS= read -r subdirectory; do
		subdirectory="${subdirectory%/}"
		if [ -d "$subdirectory" ]; then
			if [[ " ${ignore[*]} " =~ " ${subdirectory##*/} " ]]; then
				continue
			fi
			check_directory "$subdirectory"
		fi
	done < <(fd --type d -d 1 . "$dir")
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

mode="extra_branches"
echo
echo "Checking for extra branches"

for d in "${dirs[@]}"; do
	check_directory "$d"
done

if [[ "$check_ssh" -eq 1 ]]; then
	mode="ssh"
	echo
	echo "Checking for SSH remotes"

	for d in "${dirs[@]}"; do
		check_directory "$d"
	done
fi
