#!/bin/bash
#This is my main script to run benchmarks in parallel with sensor collection
#KrNikov 2014

if [ "$#" -eq 0 ]; then
  echo "This program requires inputs. Type -h for help." >&2
  exit 1
fi

#Flags to enable different functionality
BENCH_EXEC_CHOSEN=0
BENCH_SAVE_CHOSEN=0
EVENTS_SAVE_CHOSEN=0
SAMPLE_TIME=0
CPU=-1

#main loop b=big L=LITTLE s=save directory n=specify number of runs -t=benchmark directory -h=help
#requires getops, but this should not be an issue since ints built in bash
while getopts ":bLx:t:s:h" opt;
do
    case $opt in
        b|L)
            #Set flag name
                if [[ $opt == L && $CPU == -1 ]]; then
                        CPU=0
                elif [[ $opt == b && $CPU == -1 ]]; then
                        CPU=4
		else
			echo "Invalid input: option -$opt has already been used!" >&2
	                exit 1
                fi
		;;

        #specify the benchmark executable to be ran
        x)
            if (( $BENCH_EXEC_CHOSEN )); then
                echo "Invalid input: option -x has already been used!" >&2
                exit 1
            fi
            #Make sure the benchmark directory selected exists
            if [[ ! -x $OPTARG ]]; then
                echo "-x $OPTARG is not an executable file or does not exist. Please enter the bechmark executable script/program!" >&2
                exit 1
            else
                bench_exec=$OPTARG
                BENCH_EXEC_CHOSEN=1
            fi
            ;;

        #specify the benchmark executable to be ran
        t)
            if (( $SAMPLE_TIME )); then
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

        #Specify the save file for benchmark output if not file is preseented the output wont be saved
        s)
           if (( $BENCH_SAVE_CHOSEN )); then
                echo "Invalid input: option -s has already been used!" >&2
                exit 1
            else
                bench_save=$OPTARG
                BENCH_SAVE_CHOSEN=1
            fi
            ;;


        h)
            echo "Available flags and options:" >&2
            echo "-b -> turn on collection for big core (CPU4)"
            echo "-L -> turn on collection for LITTLE core (CPU0)"
            echo "-s [FILE] -> specify a save file for the results of the benchmark executable. If flag is not specified output is not saved."
            echo "-x [DIRECTORY] -> specify the benchmark executable to be run. In multiple benchmarks are to be ran, put them all in a script and set that."
            echo "-t [NUMBER] -> specify sample frequency for event collection in ms."
            echo "Mandatory options are: -b or -L; -x [DIR]; -t [NUM]"
            echo "You can group flags with no options together, flags are separated with spaces"
            exit 0
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
if (( $CPU == -1 )); then
	echo "Please select CPU affinity with -b or -L flags" >&2
	exit 1
fi

if (( !$BENCH_EXEC_CHOSEN )); then
	echo "Invalid input: option -x (benchmark executble) has not been specified!" >&2
	exit 1
fi

if (( !$SAMPLE_TIME )); then
        echo "Invalid input: option -t (sample time) has not been specified!" >&2
        exit 1
fi

#Programmable head line and column separator. By default I assume data start at line 3 (first line is descriptio, second is column heads and third is actual data). Columns separated by tab(s).

ev1_name=r011 #cycles
ev2_name=r004 #l1 dcache access
ev3_name=r014 #l1 icache access 
ev4_name=r008 #instructions 
ev5_name=r013 #mem access

echo -e "Start:\t$(date +'%s%N')" >&2
echo -e "Event1 Name:\t$ev1_name" >&2
echo -e "Event2 Name:\t$ev2_name" >&2
echo -e "Event3 Name:\t$ev3_name" >&2
echo -e "Event4 Name:\t$ev4_name" >&2
echo -e "Event5 Name:\t$ev5_name" >&2

#./perf stat -e cycles,instructions,cache-references,cache-misses -x "\t" -o "del.tmp" __run $j > /dev/null 2> /dev/null
(( $BENCH_SAVE_CHOSEN )) && taskset -c $CPU ./perf stat -g --cpu $CPU -e $ev1_name,$ev2_name,$ev3_name,$ev4_name,$ev5_name -I $SAMPLE_TIME -x "\t" $bench_exec > $bench_save #2> /dev/null
(( !$BENCH_SAVE_CHOSEN )) && taskset -c $CPU ./perf stat -g --cpu $CPU -e $ev1_name,$ev2_name,$ev3_name,$ev4_name,$ev5_name -I $SAMPLE_TIME -x "\t" $bench_exec > /dev/null #2> /dev/null


