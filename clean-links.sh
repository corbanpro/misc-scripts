#!/bin/bash

find ~/.local/bin -type l ! -exec test -e {} \; -print | xargs rm
