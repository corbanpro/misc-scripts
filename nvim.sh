#!/bin/bash

if [[ $# -eq 0 ]]; then
	SESSION_PATH=~/.local/share/nvim/sessions$PWD/Session.vim
	if [ -f $SESSION_PATH ]; then
		'/Users/corbanprocuniar/bin/nvim-macos-arm64/bin/nvim' -S $SESSION_PATH
	else
		'/Users/corbanprocuniar/bin/nvim-macos-arm64/bin/nvim'
	fi
else
	'/Users/corbanprocuniar/bin/nvim-macos-arm64/bin/nvim' $*
fi
