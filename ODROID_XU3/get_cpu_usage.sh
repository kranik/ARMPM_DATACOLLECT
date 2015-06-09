#!/bin/bash

# Calculate average cpu usage per core.
#      user  nice system   idle iowait irq softirq steal guest guest_nice
# cpu0 30404 2382   6277 554768   6061   0      19    0      0          0

if [ "$#" -eq 0 ]; then
  echo "This program requires inputs. Type -h for help." >&2
  exit 1
fi

#main loop b=big L=LITTLE s=save directory n=specify number of runs -t=benchmark directory -h=help
#requires getops, but this should not be an issue since ints built in bash
while getopts ":c:ht:" opt;
do
    case $opt in
        h)
            echo "Available flags and options:" >&2
            echo "-c [CORE LIST]-> turn on collection for respective list of cores (0-3 or 4-7)"
            echo "-t [NUMBER] -> specify sample frequency for event collection in ns."
            echo "Mandatory options are: -c [NUM] -t [NUM]"
            echo "You can group flags with no options together, flags are separated with spaces"
            exit 0
            ;;

        c)
            #Make sure command has not already been processed (flag is unset)
                if [[ -n $CORE_SELECT ]]; then
                        echo "Invalid input: option -c has already been used!" >&2
                        exit 1
                else
                        if ! [[ $OPTARG =~ ^([0-7])((,[0-7])*)$ ]]; then
                                echo "Invalid input: $OPTARG needs to be 00-7 (number of cores)!" >&2
                                exit 1
                        else
				CORE_SELECT=(${OPTARG//,/$'\n'})
                        fi
                fi
                ;;

        #specify the benchmark executable to be ran
        t)
            if [[ -n $SAMPLE_TIME ]]; then
                echo "Invalid input: option -t has already been used!" >&2
                exit 1
            fi
            if (( !$OPTARG )); then
                echo "Invalid input: option -n needs to have a positive integer!" >&2
                exit 1
            else
		SAMPLE_TIME=$OPTARG
            fi
            ;;

        :)
            echo "Option: -$OPTARG requires an argument" >&2
            exit 1
            ;;

        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;

    esac
done

#Check if user has specified something to run
if [[ -z $CORE_SELECT ]]; then
        echo "Nothing to run. Expected -c flag!" >&2
        exit 1
fi

if [[ -z $SAMPLE_TIME ]]; then
        echo "Nothing to run. Expected -t flag!" >&2
        exit 1
fi

echo -e "#Timestamp\tCORE_ID\tuser%\tnice%\tsys%\tidle%\tiowait%\tirq%\tsoftiq%\tsteal%\tguest%\tguest_nice%"

declare -a COREs
declare -a COREs_st
declare -a COREs_nd
declare -a COREs_idle

TIME_CONVERT=1000000000

COREs=($(awk '{if($1 == "processor") print $3}' /proc/cpuinfo))

#Get first and last COREs and offset since the /proc/stat array omits the COREs that are disabled.
#For example if we want to collect data from CORE 4 and 5 and CORE 0 1 2 4 and 5 are enabled we need to determine that 4 adn 5 are actually positions 3 and 4.
#We do that by traversing the list of enabled COREs and recoding the indexes which store the first and last CORE_SELECT COREs
for i in `seq 0 $((${#COREs[@]} - 1))` 
do
	if (( ${COREs[$i]} == ${CORE_SELECT[0]} )); then
		CPU_FIRST=$i
	fi

	if (( ${COREs[$i]} == ${CORE_SELECT[@]:(-1)} )); then
		CPU_LAST=$i
	fi
done

A=($(sed -n '2,9p' /proc/stat))

for i in `seq $CPU_FIRST $CPU_LAST`
do
	COREs_st[$i]=$(echo "scale = 2;  ${A[$i*11+1]}  + ${A[$i*11+2]}  + ${A[$i*11+3]}  + ${A[$i*11+4]}  + ${A[$i*11+5]}  + ${A[$i*11+6]}  + ${A[$i*11+7]}  + ${A[$i*11+8]}  + ${A[$i*11+9]}  + ${A[$i*11+10]};" | bc)
done

while true; do
	#This is to convert the user input of nsecs to secs, required ofr the sleep call
	sleep `echo "scale = 10; $SAMPLE_TIME/$TIME_CONVERT;" | bc`
	C=($(sed -n '2,9p' /proc/stat))
	TIMESTAMP=$(date +'%s%N')

	for i in `seq $CPU_FIRST $CPU_LAST`
	do
        	COREs_nd[$i]=$(echo "scale = 2;  ${C[$i*11+1]}  + ${C[$i*11+2]}  + ${C[$i*11+3]}  + ${C[$i*11+4]}  + ${C[$i*11+5]}  + ${C[$i*11+6]}  + ${C[$i*11+7]}  + ${C[$i*11+8]}  + ${C[$i*11+9]}  + ${C[$i*11+10]};" | bc)

	        COREs_user[$i]=$(echo "scale=2; (100 * (${C[$i*11+1]} - ${A[$i*11+1]}) / (${COREs_nd[$i]} - ${COREs_st[$i]}))" | bc)
        	COREs_nice[$i]=$(echo "scale=2; (100 * (${C[$i*11+2]} - ${A[$i*11+2]}) / (${COREs_nd[$i]} - ${COREs_st[$i]}))" | bc)
	        COREs_sys[$i]=$(echo "scale=2; (100 * (${C[$i*11+3]} - ${A[$i*11+3]}) / (${COREs_nd[$i]} - ${COREs_st[$i]}))" | bc)
		COREs_idle[$i]=$(echo "scale=2; (100 * (${C[$i*11+4]} - ${A[$i*11+4]}) / (${COREs_nd[$i]} - ${COREs_st[$i]}))" | bc)
        	COREs_iowait[$i]=$(echo "scale=2; (100 * (${C[$i*11+5]} - ${A[$i*11+5]}) / (${COREs_nd[$i]} - ${COREs_st[$i]}))" | bc)
	        COREs_irq[$i]=$(echo "scale=2; (100 * (${C[$i*11+6]} - ${A[$i*11+6]}) / (${COREs_nd[$i]} - ${COREs_st[$i]}))" | bc)
        	COREs_softiq[$i]=$(echo "scale=2; (100 * (${C[$i*11+7]} - ${A[$i*11+7]}) / (${COREs_nd[$i]} - ${COREs_st[$i]}))" | bc)
	        COREs_steal[$i]=$(echo "scale=2; (100 * (${C[$i*11+8]} - ${A[$i*11+8]}) / (${COREs_nd[$i]} - ${COREs_st[$i]}))" | bc)
        	COREs_guest[$i]=$(echo "scale=2; (100 * (${C[$i*11+9]} - ${A[$i*11+9]}) / (${COREs_nd[$i]} - ${COREs_st[$i]}))" | bc)
        	COREs_guest_nice[$i]=$(echo "scale=2; (100 * (${C[$i*11+10]} - ${A[$i*11+10]}) / (${COREs_nd[$i]} - ${COREs_st[$i]}))" | bc)
	
		echo -e "$TIMESTAMP\tCORE_${COREs[$i]}\t${COREs_user[$i]}\t${COREs_nice[$i]}\t${COREs_sys[$i]}\t${COREs_idle[$i]}\t${COREs_iowait[$i]}\t${COREs_irq[$i]}\t${COREs_softiq[$i]}\t${COREs_steal[$i]}\t${COREs_guest[$i]}\t${COREs_guest_nice[$i]}"
		#Use C as the new A (old values)
		for j in `seq 1 10`
		do
			A[$i*11+$j]=${C[$i*11+$j]}
		done
:
		COREs_st[$i]=${COREs_nd[$i]}	
	done
done

