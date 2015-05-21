#!/bin/bash

#RUNTIME Environment
#export CCC_RE=lli
#export CCC_RE=cil32-ilrun

#input arguments are CPU Frequency in MHz and header flag (whether to include header or not)

if (( $# != 1 )); then
  echo "This program requires integer header flag (0 means no header)." >&2
  exit 1
fi

(( $1 )) && echo -e "#Name\tDataset\tCPU(0) Frequency(MHz)\tStart(ns)\tEnd(ns)\tCycles per Instruction\tCache References\tCache Misses"

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
        cp /$DIR/perf .
        for j in `seq 1 1`;
        do
            touch "del.tmp"
            CPU0_freq=$((`cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq`/1000))
            t1=$(date +'%s%N')
            ./perf stat -a -e cycles,instructions,cache-references,cache-misses -x "\t" -o "del.tmp" __run $j > /dev/null 2> /dev/null
            t2=$(date +'%s%N')
            c_cycles=`awk '{if( $2 == "cycles") print $1}' "del.tmp"`
            instr=`awk '{if( $2 == "instructions") print $1}' "del.tmp"`
            c_ref=`awk '{if( $2 == "cache-references") print $1}' "del.tmp"`
            c_miss=`awk '{if( $2 == "cache-misses") print $1}' "del.tmp"`
            cpi=0
            (( $instr )) && cpi=$(echo "scale = 10; $c_cycles/$instr;" | bc )
            echo -e "$i\t$j\t$CPU0_freq\t$t1\t$t2\t$cpi\t$c_ref\t$c_miss"
            rm "del.tmp"
        done
        rm perf
        # *************************
    fi
done

