#!/bin/bash

if [[ "$(pwd)" != "/Users/corbanprocuniar/dev/go-shared" ]]; then
	if grep -q "github.com/signalscode/go-shared" go.mod; then
		go get github.com/signalscode/go-shared/pkg@latest
	fi
fi

go get . && go mod tidy

if [ -d "./vendor" ]; then
	go mod vendor
fi
