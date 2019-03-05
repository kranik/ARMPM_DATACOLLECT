#!/bin/bash
#This is my main script to run benchmarks in parallel with sensor collection
#KrNikov 2014

if [ "$#" -eq 0 ]; then
  echo "This program requires inputs. Type -h for help." >&2
  exit 1
fi

#main loop b=big L=LITTLE s=save directory n=specify number of runs -t=benchmark directory -h=help
#requires getops, but this should not be an issue since ints built in bash
while getopts ":r:c:x:t:s:e:h" opt;
do
    case $opt in        
        h)
		echo "Available flags and options:" >&2
		echo "-c [CORE LIST]-> turn on collection for respective list of cores (0-3 or 4-7)"    
            	echo "-s [FILE] -> specify a save file for the results of the benchmark executable. If flag is not specified output is not saved."
            	echo "-x [DIRECTORY] -> specify the benchmark executable to be run. In multiple benchmarks are to be ran, put them all in a script and set that."
		echo "-e [DIRECTORY] -> Specify the events to be collected. Event labels must be on line 1, separated by commas. Event RAW identifiers must be sepcified on line 2, separated by commas."
            	echo "-t [NUMBER] -> specify sample frequency for event collection in ms."
            	echo "Mandatory options are: -c [NUM} -x [DIR] -t [NUM]"
            	echo "You can group flags with no options together, flags are separated with spaces"
            	exit 0
            	;;
	c)
            #Make sure command has not already been processed (flag is unset)
                if [[ -n $CORE_RUN ]]; then
                        echo "Invalid input: option -c has already been used!" >&2
                        exit 1
                else
                        if ! [[ $OPTARG =~ ^([0-7])((,[0-7])*)$ ]]; then
                                echo "Invalid input: $OPTARG needs to be 0-7 (number of cores)!" >&2
                                exit 1
                        else
				CORE_RUN=$OPTARG
                        fi
                fi
                ;;

        #specify the benchmark executable to be ran
        x)
            if [[ -n $BENCH_EXEC_CHOSEN ]]; then
                echo "Invalid input: option -x has already been used!" >&2
                exit 1
            fi
            #Make sure the benchmark directory selected exists
            if [[ ! -x $OPTARG ]]; then
                echo "-x $OPTARG is not an executable file or does not exist. Please enter the bechmark executable script/program!" >&2
                exit 1
            else
                BENCH_EXEC=$OPTARG
            fi
            ;;

        #specify the benchmark executable to be ran
        e)
            if [[ -n $EVENTS_LIST_FILE ]]; then
                echo "Invalid input: option -e has already been used!" >&2
                exit 1
            fi
            #Make sure the benchmark directory selected exists
            if [[ ! -e $OPTARG ]]; then
                echo "-e $OPTARG does not exist. Please enter the events list file!" >&2
                exit 1
            else
                EVENTS_LIST_FILE=$OPTARG
            fi
            ;;

        #specify the sensor sample time
        t)
            if [[ -n $SAMPLE_TIME ]]; then
                echo "Invalid input: option -t has already been used!" >&2
                exit 1
            fi
            if [[ "$OPTARG" -le 0 || "$OPTARG" -gt 999999999 ]]; then
                echo "Invalid input: option -t needs to have a positive integer and be less than 999999999 to prevent overflow!" >&2
                exit 1
            else
                SAMPLE_TIME="$OPTARG"
            fi
            ;;

        #Specify the save file for benchmark output if not file is preseented the output wont be saved
        s)
           if [[ -n $BENCH_SAVE ]]; then
                echo "Invalid input: option -s has already been used!" >&2
                exit 1
            else
                BENCH_SAVE=$OPTARG
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
if [[ -z $CORE_RUN ]]; then
        echo "Nothing to run. Expected -c flag!" >&2
        exit 1
fi

if [[ -z $BENCH_EXEC ]]; then
	echo "Invalid input: option -x (benchmark executble) has not been specified!" >&2
	exit 1
fi

if [[ -z $EVENTS_LIST_FILE ]]; then
        echo "Invalid input: option -e (events list) has not been specified!" >&2
        exit 1
fi

if [[ -z $SAMPLE_TIME ]]; then
        echo "Invalid input: option -t (sample time) has not been specified!" >&2
        exit 1
fi

#Programmable head line and column separator. By default I assume data start at line 3 (first line is descriptio, second is column heads and third is actual data). Columns separated by tab(s).
EVENTS_LABELS=$(awk -v START=1 '{if (NR == START) {print $0}}' "$EVENTS_LIST_FILE")
IFS=',' read -a EVENTS_LABELS <<< "$EVENTS_LABELS"
EVENTS_LIST=$(awk -v START=2 '{if (NR == START) {print $0}}' "$EVENTS_LIST_FILE")
IFS=',' read -a EVENTS_RAW <<< "$EVENTS_LIST"

#Prepare input to bench exec file - number of cores/threads(PARSEC) or instances(cBench)
#Variable name is CORE_CHOSEN to keep it consistent with MC_XU3.sh naming
CORE_CHOSEN=$(( $(echo "$CORE_RUN" | tr -cd ',' | wc -c) + 1 ))

: << 'END'
ev1_name=r0FF #r011 #cycles
ev2_name=r01B #instructions speculative
ev3_name=r073 #integer operations speculative
ev4_name=r075 #floating point operations speculative
ev5_name=r004 #L1 data access
ev6_name=r016 #L2 access
ev7_name=r017 #L2 refill(miss)
END

echo -e "Start:\t$(date +'%s%N')" >&2
for i in $(seq 0 $(( ${#EVENTS_LABELS[@]} - 1 )))
do
	echo -e "Event $(( i+1 )) Label:\t${EVENTS_LABELS[$i]}\t\tRAW Identifier:\t${EVENTS_RAW[$i]}" >&2
done

[[ -z $BENCH_SAVE ]] && BENCH_SAVE=/dev/stdout
./perf stat -g --cpu "$CORE_RUN" -e "$EVENTS_LIST" -I "$SAMPLE_TIME" -x "\t" "$BENCH_EXEC" "$CORE_CHOSEN" "$CORE_RUN" > $BENCH_SAVE #2> /dev/null
#execute perf that follows the thread this is to provide me with a base scenario
#./perf stat -g -e $EVENTS_LIST -I $SAMPLE_TIME -x "\t" $BENCH_EXEC > $BENCH_SAVE #2> /dev/null
