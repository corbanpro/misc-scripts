#!/bin/bash

kubectl config use-context docker-desktop >/dev/null 2>&1

cd ~/dev/tilt

exec /opt/homebrew/bin/tilt "$@"
