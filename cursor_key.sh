#!/bin/bash

function single_tap {
	osascript -e 'tell application "System Events" to keystroke "q" using {control down, command down}'
}

function double_tap {
	say "double_tap"
}

function hold {
	say "hold"
}

if [ "$1" == "single_tap" ]; then
	single_tap
elif [ "$1" == "double_tap" ]; then
	double_tap
elif [ "$1" == "hold" ]; then
	hold
fi
