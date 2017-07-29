#!/bin/bash

echo -e "#Name\tStart(ns)\tEnd(ns)"

DIR="$( cd "$( dirname "$BASH_SOURCE[0]}" )" && pwd )"

if [ -f /$DIR/bench_list.data ]
then
	benchmarks=$(grep -v ^# /$DIR/bench_list.data)
else
	benchmarks=*  
fi

for i in $benchmarks
do
	t1=$(date +'%s%N')
	cset shield -e bash /$DIR/parsecexec.sh $i $1 $2 > /dev/null 2> /dev/null
	t2=$(date +'%s%N')
	echo -e "$i\t$t1\t$t2"
done
