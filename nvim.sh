#!/bin/bash

NEOVIM_PATH=~/bin/neovim/0.11/bin/nvim

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
