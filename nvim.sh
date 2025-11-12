#!/bin/bash

NEOVIM_VERSION="v0.11.5"

VERSION_FILE="$HOME/.config/nvvm/version"

if [ -s "$VERSION_FILE" ]; then
	NEOVIM_VERSION="$(<"$VERSION_FILE")"
fi

NEOVIM_PATH=~/bin/neovim/${NEOVIM_VERSION}/bin/nvim

if [[ $# -eq 0 ]]; then
	SESSION_PATH=~/.local/share/nvim/sessions$PWD/Session.vim
	if [ -f $SESSION_PATH ]; then
		"$NEOVIM_PATH" -S $SESSION_PATH
	else
		"$NEOVIM_PATH"
	fi
else
	"$NEOVIM_PATH" $@
fi
