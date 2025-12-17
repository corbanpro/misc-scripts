#!/bin/bash

if [[ $1 != "-rf" ]]; then
	du -sh $(go env GOCACHE)
else
	echo "[$(date)] deleting go cache"
	/usr/local/go/bin/go clean -cache -modcache -testcache
	echo "[$(date)] deleted go cache"
fi
