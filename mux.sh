#!/bin/bash

export NGINX_CONF=znginx.conf
export rs_cmd="./release-status.mac"

tmux kill-server 2>/dev/null
nginx -s stop 2>/dev/null

cd ~/dev/data-fetch/
make run_deps
tmuxinator start $1
