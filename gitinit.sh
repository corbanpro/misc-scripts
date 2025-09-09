#!/bin/bash

if [ -z "$1" ]; then
	echo "Error: missing argument"
	exit 1
fi

mkdir $1
cd $1

echo "# $1" >README.md

git init
git add .
git commit -m "initial commit"
git branch -M main

gh repo create $1 --public --source=. --push

# git remote add origin "https://github.com/corbanpro/$1.git"
# git push -u origin main
