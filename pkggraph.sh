#!/bin/bash

FILTER="${1:-}"

{
	echo "digraph G {"
	echo "  rankdir=LR;"
	echo "  graph [overlap=false, splines=true];"
	echo "  node [shape=box, style=filled, fillcolor=lightblue, fontname=Helvetica];"
	echo "  edge [color=gray50];"
	go list -deps -json ./... | jq -r --arg F "$FILTER" '
    .ImportPath as $pkg
    | .Imports[]? as $imp
    | select(
        ($F == "") or
        ($pkg | contains($F)) or
        ($imp | contains($F))
      )
    | "\"\($pkg)\" [fillcolor=" + (if ($pkg | contains($F)) then "orange" else "lightblue" end) + "];"
    , "\"\($imp)\" [fillcolor=" + (if ($imp | contains($F)) then "orange" else "lightblue" end) + "];"
    , "\"\($pkg)\" -> \"\($imp)\";"
  '
	echo "}"
} | dot -Tpdf -Gdpi=300 >pkg-graph.pdf
