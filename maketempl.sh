#!/bin/bash

if go tool -n templ >/dev/null 2>&1; then
	go tool templ generate -log-level=error
else
	templ generate -log-level=error
fi
