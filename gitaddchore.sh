#!/bin/bash

if ! git diff --cached --quiet; then
	echo "error: staged changes already present; unstage or commit them first" >&2
	exit 1
fi

commit_if_staged() {
	local msg="$1"
	shift
	git add -- "$@"
	if ! git diff --cached --quiet; then
		git commit -m "$msg"
	fi
}

commit_if_staged "chore: vendor" go.mod go.sum vendor
commit_if_staged "test: update tests" ':(glob)**/*_test.go'
commit_if_staged "chore: generate fakes" ':(glob)**/fake_*.go'
