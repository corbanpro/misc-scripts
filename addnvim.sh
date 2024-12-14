#!/bin/bash

mkdir -p ~/temp/nvim-linux64 ~/.config/nvim &&
        curl -o ~/temp/nvim-linux64.tar.gz -L "https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz" &&
        tar -xzf ~/temp/nvim-linux64.tar.gz -C ~/temp &&
        sudo mv ~/temp/nvim-linux64/ /usr/local/ &&
        rm -rf ~/temp &&
        git clone https://github.com/corbanpro/neovim-config.git ~/.config/nvim
