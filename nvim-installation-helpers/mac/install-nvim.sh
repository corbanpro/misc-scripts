#!/bin/bash

if [[ -z "$DOWNLOAD_URL" ]]; then
	echo "Error: DOWNLOAD_URL is not set."
	exit 1
fi

mkdir -p ~/temp ~/.config/nvim &&
	rm -rf ~/temp/nvim-macos-arm64/ ~/temp/nvim-macos-arm64.tar.gz &&
	echo "Downloading: $DOWNLOAD_URL" &&
	curl -o ~/temp/nvim-macos-arm64.tar.gz -L "$DOWNLOAD_URL" &&
	tar -xzf ~/temp/nvim-macos-arm64.tar.gz -C ~/temp &&
	sudo rm -rf ~/bin/nvim-macos-arm64 &&
	sudo mv ~/temp/nvim-macos-arm64 ~/bin &&
	nvim --version
