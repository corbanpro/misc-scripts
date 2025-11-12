#!/bin/bash

set -e

use() {
	USER_VERSION=$1
	VERSIONS_DIR="$HOME/bin/neovim/"
	# Collect directories into an array
	VERSIONS=()
	for dir in "$VERSIONS_DIR"/*/; do
		[ -d "$dir" ] || continue
		VERSIONS+=("$(basename "$dir")")
	done

	# Check if input is in the list
	if printf '%s\n' "${VERSIONS[@]}" | grep -qx "$USER_VERSION"; then
		mkdir -p ~/.config/nvvm && touch ~/.config/nvvm/version
		echo $USER_VERSION >~/.config/nvvm/version
		echo "Now using version: $USER_VERSION"
	else
		echo "Invalid version! Available versions:"
		for v in "${VERSIONS[@]}"; do
			echo "  $v"
		done
		exit 1
	fi
}

install() {
	USER_VERSION=$1
	DOWNLOAD_URL="https://github.com/neovim/neovim/releases/download/$USER_VERSION/nvim-macos-arm64.tar.gz"
	TAR_PATH="$HOME/temp/nvim-macos-arm64.tar.gz"
	TEMP_OUTPUT_DIR="$HOME/temp/nvim-macos-arm64/"
	OUTPUT_DIR="$HOME/bin/neovim/$USER_VERSION"

	mkdir -p ~/temp
	rm -rf $TAR_PATH $TEMP_OUTPUT_DIR
	curl -o $TAR_PATH -L "$DOWNLOAD_URL"
	xattr -c $TAR_PATH
	tar xzf $TAR_PATH -C ~/temp
	rm -rf $OUTPUT_DIR
	mv $TEMP_OUTPUT_DIR $OUTPUT_DIR

	use $USER_VERSION
}

help() {
	echo -e "Usage:
	nvvm install VERSION
	nvvm use VERSION"
}

case "$1" in
use) use ${@:2} ;;
install) install ${@:2} ;;
*) help ;;
esac
