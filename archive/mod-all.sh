#!/bin/bash
FILES=$(fd go.mod ~/dev)

for F in $FILES; do
	F=$(dirname $F)
	cd $F
	echo -e "\n${C_CYAN}updating $F${C_RESET}"
	mod
done
