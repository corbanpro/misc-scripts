#!/bin/bash

cd ~/temp
git clone https://github.com/neovim/neovim
git checkout release-0.11
cd neovim
rm -r build/ # clear the CMake cache
# make CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=$HOME/.local/bin/neovim"
CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=$HOME/bin/neovim/0.11" make CMAKE_BUILD_TYPE=Release
make install
