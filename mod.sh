#!/bin/bash

go get github.com/signalscode/go-shared@latest 2>/dev/null

go get . &&
	go mod tidy &&
	go mod vendor
