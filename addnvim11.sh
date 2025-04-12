#!/bin/bash

mkdir -p ~/temp ~/.config/nvim &&
	rm -rf ~/temp/nvim-linux-x86_64/ ~/temp/nvim-linux-x86_64.tar.gz &&
	curl -o ~/temp/nvim-linux-x86_64.tar.gz -L "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz" &&
	tar -xzf ~/temp/nvim-linux-x86_64.tar.gz -C ~/temp &&
	sudo rm -rf /usr/local/nvim &&
	sudo mv ~/temp/nvim-linux-x86_64 /usr/local/nvim/ &&
	nvim --version
