#!/bin/bash

if [[ -z "$DOWNLOAD_URL" ]]; then
	echo "Error: DOWNLOAD_URL is not set."
	exit 1
fi

mkdir -p ~/temp ~/.config/nvim &&
	rm -rf ~/temp/nvim-linux-x86_64/ ~/temp/nvim-linux-x86_64.tar.gz &&
	curl -o ~/temp/nvim-linux-x86_64.tar.gz -L "$DOWNLOAD_URL" &&
	tar -xzf ~/temp/nvim-linux-x86_64.tar.gz -C ~/temp &&
	sudo rm -rf /usr/local/nvim &&
	sudo mv ~/temp/nvim-linux-x86_64 /usr/local/nvim/ &&
	nvim --version
