#!/bin/bash

#RUNTIME Environment
#export CCC_RE=lli
#export CCC_RE=cil32-ilrun

#Input arguments is header flag enable (whether to include header or not)

if (( $# != 1 )); then
  echo "This program requires integer header flag (0 means no header)." >&2
  exit 1
fi

(( $1 )) && echo -e "#Name\tDataset\tFrequency(CPU0)(Mhz)\tTemperature(SoC)(C)\tStart(ns)\tEnd(ns)\tLITTLE Energy(J)\tbig Energy(J)\tCycles\tInstructions\tCache References\tCache Misses\tBus Cycles"

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
               		L_nrg1=$((`cat /sys/class/hwmon/hwmon6/energy1_input`))
                	b_nrg1=$((`cat /sys/class/hwmon/hwmon5/energy1_input`))
	                t1=$(date +'%s%N')
       		        ./perf stat -e cycles,instructions,cache-references,cache-misses,bus-cycles -x "\t" -o "del.tmp" __run $j > /dev/null 2> /dev/null
               		t2=$(date +'%s%N')
               		L_nrg2=$((`cat /sys/class/hwmon/hwmon6/energy1_input`))
                	b_nrg2=$((`cat /sys/class/hwmon/hwmon5/energy1_input`))
       		        SOC_t1=$((`cat /sys/class/hwmon/hwmon2/temp1_input`))
			SOC_temp=$(echo "scale = 10; ($SOC_t1)/1000;" | bc )
			c_cycles=`awk '{if( $2 == "cycles") print $1}' "del.tmp"`
                	instr=`awk '{if( $2 == "instructions") print $1}' "del.tmp"`
        	        c_ref=`awk '{if( $2 == "cache-references") print $1}' "del.tmp"`
       	        	c_miss=`awk '{if( $2 == "cache-misses") print $1}' "del.tmp"`
        	        b_cycles=`awk '{if( $2 == "bus-cycles") print $1}' "del.tmp"`
			L_energy=$(echo "scale = 10; ($L_nrg2-$L_nrg1)/1000000;" | bc )
			b_energy=$(echo "scale = 10; ($b_nrg2-$b_nrg1)/1000000;" | bc )
	                echo -e "$i\t$j\t$CPU0_freq\t$SOC_temp\t$t1\t$t2\t$L_energy\t$b_energy\t$c_cycles\t$instr\t$c_ref\t$c_miss\t$b_cycles"
       		        rm "del.tmp"
		done  
       		rm perf
            	# *************************
	fi
done

