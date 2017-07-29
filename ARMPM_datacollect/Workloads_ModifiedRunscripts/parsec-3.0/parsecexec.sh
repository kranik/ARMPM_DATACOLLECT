#!/bin/bash

DIR="$( cd "$( dirname "$BASH_SOURCE[0]}" )" && pwd )"
if [[ -n $3 ]]; then
	taskset -c $3 bash /$DIR/bin/parsecmgmt -a run -p $1 -i native -n $2 -k -c gcc-openmp
else
	bash /$DIR/bin/parsecmgmt -a run -p $1 -i native -n $2 -k -c gcc-openmp
fi
