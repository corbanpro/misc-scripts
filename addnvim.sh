#!/bin/bash

mkdir -p ~/temp ~/.config/nvim &&
	curl -o ~/temp/nvim-linux-x86_64.tar.gz -L "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz" &&
	tar -xzf ~/temp/nvim-linux-x86_64.tar.gz -C ~/temp &&
	sudo mv ~/temp/nvim-linux-x86_64 /usr/local/nvim/ &&
	git clone https://github.com/corbanpro/neovim-config.git ~/.config/nvim
