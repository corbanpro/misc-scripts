#!/bin/bash

export NGINX_CONF=znginx.conf
export rs_cmd="./release-status.mac"

tmux kill-server
nginx -s stop

cd ~/dev/data-fetch/
make run_deps
tmuxinator start devenv-basic
