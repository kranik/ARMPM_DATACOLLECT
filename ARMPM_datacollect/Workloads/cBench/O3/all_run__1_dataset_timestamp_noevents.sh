#!/bin/bash

#RUNTIME Environment
#export CCC_RE=lli
#export CCC_RE=cil32-ilrun

#Input arguments is header flag enable (whether to include header or not)

echo -e "#Name\tStart(ns)\tEnd(ns)"

DIR="$( cd "$( dirname "$BASH_SOURCE[0]}" )" && pwd )"

if [ -f /$DIR/bench_list ]
then
	benchmarks=`grep -v ^# /$DIR/bench_list`
else
	benchmarks=*  
fi

for i in $benchmarks
do
        if [ -d "/$DIR/$i/src_work" ] 
        then
            	# *** process directory ***
            	cd /$DIR/$i/src_work
	        for j in `seq 1 1`;
        	do
	                t1=$(date +'%s%N')
       		        ./__run $j > /dev/null 2> /dev/null
               		t2=$(date +'%s%N')
	                echo -e "$i\t$t1\t$t2"
		done  
            	# *************************
	fi
done

