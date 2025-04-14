#!/bin/bash

export DOWNLOAD_URL=https://github.com/neovim/neovim/releases/download/v0.10.4/nvim-linux-x86_64.tar.gz
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
$DIR/install-nvim.sh

git -C ~/.config/nvim/ checkout 10
