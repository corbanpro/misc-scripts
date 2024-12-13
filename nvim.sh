#!/bin/bash

if [[ $# -eq 0 ]]; then
    SESSION_PATH=~/.local/share/nvim/sessions$PWD/Session.vim
    if [ -f $SESSION_PATH ]; then
        '/usr/local/nvim-linux64/bin/nvim' -S $SESSION_PATH
    else
        '/usr/local/nvim-linux64/bin/nvim'
    fi
else
    '/usr/local/nvim-linux64/bin/nvim' $*
fi
