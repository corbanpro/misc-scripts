#!/bin/bash

mkdir -p ~/temp/nvim-linux64 &&
        curl -o ~/temp/nvim-linux64.tar.gz -L "https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz" &&
        echo "starting extraction" &&
        tar -xzf ~/temp/nvim-linux64.tar.gz -C ~/temp &&
        echo "extraction complete" &&
        echo "moving files" &&
        sudo mv ~/temp/nvim-linux64/ /usr/local/ &&
        rm -rf ~/temp &&
        echo "files moved" &&
        echo "downloading config" &&
        git clone https://github.com/corbanpro/neovim-config.git "${XDG_CONFIG_HOME:-$HOME/.config}"/nvim &&
        echo "config downloaded"
