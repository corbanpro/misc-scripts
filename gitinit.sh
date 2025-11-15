#!/bin/bash

REPO_NAME=$1

if [ -z "$REPO_NAME" ]; then
	argerr gitinit
	echo "USAGE: gitinit <repo_name>"
	exit 1
fi

mkdir $REPO_NAME
cd $REPO_NAME

echo "# $REPO_NAME" >README.md

git init
git add .
git commit -m "initial commit"
git branch -M main

gh repo create $REPO_NAME --public --source=. --push
