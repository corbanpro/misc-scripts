#!/bin/zsh

make templ || templ generate 2> >(grep --color=always -v "Complete")
local gen_status=${pipestatus[1]:-1}
if [[ "$gen_status" -eq 0 ]]; then
	go vet "${1:-./...}"
fi
