#!/bin/bash

function single_tap {
	echo "restarting server > $(date)" >~/dev/nerve/.reload
	echo "restarting server > $(date)" >~/dev/signals-core/.reload
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
