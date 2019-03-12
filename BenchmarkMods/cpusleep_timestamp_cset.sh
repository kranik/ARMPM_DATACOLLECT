#!/bin/bash

echo -e "#Name\tStart(ns)\tEnd(ns)"

t1=$(date +'%s%N')
cset shield -e sleep 60s > /dev/null 2> /dev/null
t2=$(date +'%s%N')
echo -e "sleep\t$t1\t$t2"

