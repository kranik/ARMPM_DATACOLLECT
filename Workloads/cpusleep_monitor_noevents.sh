#!/bin/bash

#RUNTIME Environment
#export CCC_RE=lli
#export CCC_RE=cil32-ilrun

#Input arguments is header flag enable (whether to include header or not)

echo -e "#Name\tStart(ns)\tEnd(ns)"

t1=$(date +'%s%N')
taskset -c $1 sleep 600s > /dev/null 2> /dev/null
t2=$(date +'%s%N')
echo -e "sleep\t$t1\t$t2"

