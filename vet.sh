#!/bin/bash

DIR="${1:-./...}"

maketempl

go vet $DIR
