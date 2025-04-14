#!/bin/bash

sudo rm -rf ~/.config/nvim/ ~/.local/share/nvim ~/.local/state/nvim/ /usr/local/nvim/ &&
	mkdir -p ~/temp ~/.config/nvim &&
	git clone https://github.com/corbanpro/neovim-config.git ~/.config/nvim

echo "success"
