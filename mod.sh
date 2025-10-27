#!/bin/bash

if [[ "$(pwd)" != "/Users/corbanprocuniar/dev/go-shared" ]]; then
	go get github.com/signalscode/go-shared/pkg@latest
fi

go get . &&
	go mod tidy &&
	go mod vendor
