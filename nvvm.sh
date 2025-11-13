#!/bin/bash

set -e

VERSIONS_DIR="$HOME/bin/neovim"
PLATFORM="nvim-macos-arm64"

use() {
	REQUESTED_VERSION=$1
	# Collect directories into an array
	VERSIONS=()
	for dir in "$VERSIONS_DIR"/*/; do
		[ -d "$dir" ] || continue
		VERSIONS+=("$(basename "$dir")")
	done

	# Check if input is in the list
	if printf '%s\n' "${VERSIONS[@]}" | grep -qx "$REQUESTED_VERSION"; then
		mkdir -p ~/.config/nvvm && touch ~/.config/nvvm/version
		echo $REQUESTED_VERSION >~/.config/nvvm/version
		echo -e "\n${C_CYAN}Now using version: ${REQUESTED_VERSION}${C_RESET}"
	else
		echo "Invalid version! Available versions:"
		for v in "${VERSIONS[@]}"; do
			echo "  $v"
		done
		exit 1
	fi
}

install() {
	TEMP_DIR="$VERSIONS_DIR/temp"
	REQUESTED_VERSION=$1
	DOWNLOAD_URL="https://github.com/neovim/neovim/releases/download/${REQUESTED_VERSION}/${PLATFORM}.tar.gz"
	TEMP_OUTPUT_DIR="${TEMP_DIR}/${PLATFORM}"
	TAR_PATH="${TEMP_OUTPUT_DIR}.tar.gz"
	OUTPUT_DIR="${VERSIONS_DIR}/${REQUESTED_VERSION}"

	mkdir -p $TEMP_DIR
	rm -rf "$TEMP_DIR/*"

	echo "Downloading neovim from ${DOWNLOAD_URL}..."
	curl -o $TAR_PATH -L $DOWNLOAD_URL -s
	xattr -c $TAR_PATH
	echo "extracting files..."
	tar xzf $TAR_PATH -C $TEMP_DIR

	echo "installing neovim at ${OUTPUT_DIR}..."
	rm -rf $OUTPUT_DIR
	mv $TEMP_OUTPUT_DIR $OUTPUT_DIR
	rm -rf $TEMP_DIR

	use $REQUESTED_VERSION
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
