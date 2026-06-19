#!/bin/bash

cmd="kubectl exec -it $1 -- /bin/bash"

echo $cmd

bash -c "$cmd"
