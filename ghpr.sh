#!/usr/bin/env bash
# Commit the current tree, push the branch, and open a pull request for one repo.
#
# Usage:
#   ghpr.sh --repo <path> --branch <name> --commit <message> --title <pr title>
#
# The pull request body is --body, or stdin when stdin is not a terminal.
# With neither, the commit message is the body.
#
# Call once per repository. This script does not choose the repo, branch,
# commit message, or title, and it does not edit source files.

set -euo pipefail

usage() {
	cat <<'EOF'
Usage: ghpr.sh --repo <path> --branch <name> --commit <message> --title <pr title> [--body <text>]

The pull request body may be passed with --body or on stdin.
EOF
}

repo=""
branch=""
commit=""
title=""
body=""

while [[ $# -gt 0 ]]; do
	case "$1" in
	--repo)
		repo="${2:-}"
		shift 2
		;;
	--branch)
		branch="${2:-}"
		shift 2
		;;
	--commit)
		commit="${2:-}"
		shift 2
		;;
	--title)
		title="${2:-}"
		shift 2
		;;
	--body)
		body="${2:-}"
		shift 2
		;;
	-h | --help)
		usage
		exit 0
		;;
	*)
		echo "unknown argument: $1" >&2
		usage >&2
		exit 2
		;;
	esac
done

if [[ -z "$repo" || -z "$branch" || -z "$commit" || -z "$title" ]]; then
	usage >&2
	exit 2
fi

if [[ "$branch" == *" "* || "$branch" == */ || "$branch" == /* ]]; then
	echo "invalid branch name: $branch" >&2
	exit 2
fi

root=$(git -C "$repo" rev-parse --show-toplevel)
cd "$root"

if [[ -z "$body" && ! -t 0 ]]; then
	body=$(cat)
fi
if [[ -z "$body" ]]; then
	body="$commit"
fi

commit_re='^[a-z]+: '
title_re='^[a-z]+\([^)]+\): '
if [[ ! "$commit" =~ $commit_re ]]; then
	echo "warning: commit subject is not '<type>: message'" >&2
fi
if [[ ! "$title" =~ $title_re ]]; then
	echo "warning: PR title is not '<type>(scope): title'" >&2
fi

base=$(git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null || true)
base="${base#origin/}"
if [[ -z "$base" ]]; then
	if git show-ref --verify --quiet refs/heads/main; then
		base=main
	elif git show-ref --verify --quiet refs/heads/master; then
		base=master
	else
		echo "cannot detect the default branch" >&2
		exit 1
	fi
fi

current=$(git branch --show-current)
if [[ -z "$current" ]]; then
	echo "detached HEAD; checkout a branch first" >&2
	exit 1
fi

if [[ "$current" != "$branch" ]]; then
	if [[ "$current" == "$base" ]]; then
		git checkout -b "$branch"
	elif [[ "$current" =~ ^[0-9]+- ]]; then
		echo "refusing to leave issue branch $current" >&2
		exit 2
	elif git rev-parse --abbrev-ref --symbolic-full-name '@{upstream}' >/dev/null 2>&1; then
		echo "refusing to rename published branch $current to $branch" >&2
		exit 2
	else
		git branch -m "$branch"
	fi
fi

is_secret() {
	local base="${1##*/}"
	case "$base" in
	.env | .env.* | credentials.json | credentials*.json | service-account.json | *.pem | id_rsa | *.p12)
		return 0
		;;
	*)
		return 1
		;;
	esac
}

secret=0
while IFS= read -r line; do
	[[ -z "$line" ]] && continue
	path="${line:3}"
	path="${path##* -> }"
	if is_secret "$path"; then
		echo "refusing to commit secret: $path" >&2
		secret=1
	fi
done < <(git status --porcelain)
if [[ "$secret" -ne 0 ]]; then
	exit 1
fi

if [[ -n "$(git status --porcelain)" ]]; then
	git add -A
	git commit -m "$commit"
fi

ahead=$(git rev-list --count "$base"..HEAD)
if [[ "$ahead" -eq 0 ]]; then
	echo "nothing to pull-request: no commits ahead of $base" >&2
	exit 1
fi

git push -u origin HEAD
upstream=$(git rev-parse --abbrev-ref --symbolic-full-name '@{upstream}')
if [[ "$upstream" != "origin/$branch" ]]; then
	git branch --set-upstream-to="origin/$branch"
	upstream=$(git rev-parse --abbrev-ref --symbolic-full-name '@{upstream}')
fi
if [[ "$upstream" != "origin/$branch" ]]; then
	echo "upstream is $upstream, expected origin/$branch" >&2
	exit 1
fi

if url=$(gh pr view --json url -q .url 2>/dev/null); then
	echo "$url"
	exit 0
fi

gh pr create --base "$base" --head "$branch" --title "$title" --body "$body"
