#!/bin/bash

cd ~/dev

rg --glob "!/*/migrations/**/*" \
	--glob "!/saved-queries" \
	--glob "!/**/*bundle.js" \
	--glob "!/**/*bundle.yaml" \
	--glob "!/**/resource/dist/**/*" \
	--glob "!/**/*.min.mjs" \
	--glob "!/**/*.mjs.map" \
	--glob "!/**/vendor/**/*" \
	--glob "!signals-nerve/**/*" \
	--glob "!temp/" \
	-w --case-sensitive "$1" -l |
	xargs rg "flag" -l |
	xargs rg -w "$1"
